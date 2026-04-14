@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 收集output.mp4文件到当前目录
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "OUTPUT_DIR=%~dp0collected_videos"

echo 源目录: %SOURCE_DIR%
echo 输出目录: %OUTPUT_DIR%
echo.

REM 创建输出目录
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo 已创建输出目录
    echo.
)

echo 正在搜索并复制output.mp4文件...
echo.

set /a count=0
set /a copied=0

REM 遍历所有子文件夹查找output.mp4
for /r "%SOURCE_DIR%" %%f in (output.mp4) do (
    set /a count+=1
    set "file_path=%%f"
    set "folder_name=%%~dpf"
    set "parent_folder=%%~dpf"
    
    REM 获取父文件夹名称
    for %%p in ("!parent_folder:~0,-1!") do set "folder_name=%%~nxp"
    
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    
    echo [!count!] 来自文件夹: !folder_name!
    echo     大小: !size_mb! MB
    
    REM 使用文件夹名称重命名并复制
    set "new_name=!folder_name!.mp4"
    copy "%%f" "%OUTPUT_DIR%\!new_name!" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a copied+=1
        echo     ✓ 已保存为: !new_name!
    ) else (
        echo     ✗ 复制失败
    )
    echo.
)

if %count% equ 0 (
    echo ========================================
    echo 未找到任何output.mp4文件！
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. sp.exe 还未执行或执行失败
    echo 2. 文件名不是output.mp4
    echo 3. 文件保存在其他位置
    echo.
    echo 建议：
    echo 1. 先运行 process_bilibili_videos.bat 处理视频
    echo 2. 手动检查子文件夹中是否有output.mp4
    echo 3. 运行 check_generated_files.bat 查看所有视频文件
) else (
    echo ========================================
    echo 完成！
    echo ========================================
    echo 找到: %count% 个output.mp4文件
    echo 复制: %copied% 个文件
    echo.
    echo 文件保存在: %OUTPUT_DIR%
    echo.
    echo 文件已按文件夹名称重命名
)

echo.
pause
