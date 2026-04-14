@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 复制MP4文件
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "TARGET_DIR=D:\PC_test\Videos"

echo 源目录: %SOURCE_DIR%
echo 目标目录: %TARGET_DIR%
echo.

REM 创建目标目录
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    echo 已创建目标目录
    echo.
)

echo 开始复制...
echo.

set /a count=0
set /a copied=0

REM 遍历所有子文件夹查找mp4文件
for /r "%SOURCE_DIR%" %%f in (*.mp4) do (
    set /a count+=1
    set "file_name=%%~nxf"
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    
    echo [!count!] !file_name! (!size_mb! MB)
    
    xcopy "%%f" "%TARGET_DIR%\" /Y /Q >nul 2>&1
    if !errorlevel! equ 0 (
        set /a copied+=1
        echo     ✓ 已复制
    ) else (
        echo     ✗ 失败
    )
)

echo.
echo ========================================
echo 完成！
echo ========================================
echo 找到: %count% 个mp4文件
echo 复制: %copied% 个文件
echo.
echo 文件保存在: %TARGET_DIR%
echo.
pause
