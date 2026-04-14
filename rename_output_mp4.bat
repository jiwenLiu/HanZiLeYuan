@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 重命名output.mp4文件
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"

echo 源目录: %SOURCE_DIR%
echo.
echo 正在搜索并重命名output.mp4文件...
echo.

set /a count=0
set /a renamed=0

REM 遍历所有子文件夹查找output.mp4
for /r "%SOURCE_DIR%" %%f in (output.mp4) do (
    set /a count+=1
    set "file_path=%%f"
    set "folder_path=%%~dpf"
    
    REM 获取父文件夹名称
    for %%p in ("!folder_path:~0,-1!") do set "folder_name=%%~nxp"
    
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    
    echo [!count!] 文件夹: !folder_name!
    echo     原文件: output.mp4
    echo     大小: !size_mb! MB
    
    REM 重命名为文件夹名称
    set "new_name=!folder_name!.mp4"
    set "new_path=!folder_path!!new_name!"
    
    REM 检查目标文件是否已存在
    if exist "!new_path!" (
        echo     ⚠ 目标文件已存在，跳过
    ) else (
        ren "%%f" "!new_name!" 2>nul
        if !errorlevel! equ 0 (
            set /a renamed+=1
            echo     ✓ 已重命名为: !new_name!
        ) else (
            echo     ✗ 重命名失败
        )
    )
    echo.
)

if %count% equ 0 (
    echo ========================================
    echo 未找到任何output.mp4文件！
    echo ========================================
    echo.
    echo 可能的原因：
    echo 1. sp.exe 还未执行
    echo 2. 文件已经被重命名
    echo 3. 文件名不是output.mp4
) else (
    echo ========================================
    echo 完成！
    echo ========================================
    echo 找到: %count% 个output.mp4文件
    echo 重命名: %renamed% 个文件
    echo.
    echo 文件保存在各自的文件夹中
)

echo.
pause
