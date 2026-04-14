@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 收集MP4文件到当前目录
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "OUTPUT_DIR=%~dp0mp4_output"

echo 源目录: %SOURCE_DIR%
echo 输出目录: %OUTPUT_DIR%
echo.

REM 创建输出目录
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo 已创建输出目录
    echo.
)

echo 正在搜索并复制mp4文件...
echo.

set /a count=0
set /a copied=0

REM 遍历所有子文件夹查找mp4文件
for /r "%SOURCE_DIR%" %%f in (*.mp4) do (
    set /a count+=1
    set "file_path=%%f"
    set "file_name=%%~nxf"
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    
    echo [!count!] !file_name! (!size_mb! MB)
    echo     来源: %%~dpf
    
    REM 复制文件到当前目录的mp4_output文件夹
    copy "%%f" "%OUTPUT_DIR%\!file_name!" >nul 2>&1
    if !errorlevel! equ 0 (
        set /a copied+=1
        echo     ✓ 已复制到当前目录
    ) else (
        echo     ✗ 复制失败
    )
    echo.
)

if %count% equ 0 (
    echo ========================================
    echo 未找到任何mp4文件！
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. sp.exe 还未生成文件
    echo 2. sp.exe 生成的文件不是mp4格式
    echo 3. 处理过程出错
    echo.
    echo 建议：
    echo 1. 手动检查子文件夹中的文件
    echo 2. 查看 sp.exe 的输出信息
    echo 3. 尝试手动运行一次: sp.exe "文件夹路径" 2
) else (
    echo ========================================
    echo 完成！
    echo ========================================
    echo 找到: %count% 个文件
    echo 复制: %copied% 个文件
    echo.
    echo 文件保存在: %OUTPUT_DIR%
)

echo.
pause
