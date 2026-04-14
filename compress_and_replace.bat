@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 视频压缩并替换工具
echo ========================================
echo.
echo ⚠️  警告：此脚本会直接替换原视频文件！
echo ⚠️  建议先备份原文件！
echo.
echo 源目录: D:\PC_test\Videos
echo 目标目录: entry\src\main\resources\rawfile\videos
echo.
set /p confirm="确认继续？(Y/N): "

if /i not "%confirm%"=="Y" (
    echo 已取消操作
    pause
    exit /b
)

REM 设置目录
set "SOURCE_DIR=D:\PC_test\Videos"
set "TARGET_DIR=entry\src\main\resources\rawfile\videos"
set "TEMP_DIR=D:\PC_test\Videos\temp_compressed"

REM 创建临时目录
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo 步骤1: 压缩视频到临时目录...
echo.

set /a count=0
set /a success=0

REM 压缩所有视频到临时目录
for %%f in ("%SOURCE_DIR%\*.mp4") do (
    set /a count+=1
    set "filename=%%~nxf"
    
    echo [!count!] 压缩: !filename!
    
    ffmpeg -i "%%f" -vcodec h264 -acodec aac -b:v 1.5M -b:a 128k -y "%TEMP_DIR%\!filename!" 2>nul
    
    if !errorlevel! equ 0 (
        set /a success+=1
        
        REM 显示压缩后大小
        for %%c in ("%TEMP_DIR%\!filename!") do (
            set "size=%%~zc"
            set /a size_mb=!size!/1024/1024
            echo     大小: !size_mb! MB ✓
        )
    ) else (
        echo     ✗ 失败
    )
    echo.
)

echo.
echo 步骤2: 复制到项目目录...
echo.

REM 检查目标目录是否存在
if not exist "%TARGET_DIR%" (
    echo 错误：目标目录不存在: %TARGET_DIR%
    echo 请确保在项目根目录运行此脚本
    pause
    exit /b
)

REM 复制压缩后的文件到项目
set /a copied=0
for %%f in ("%TEMP_DIR%\*.mp4") do (
    set "filename=%%~nxf"
    echo 复制: !filename!
    copy /Y "%%f" "%TARGET_DIR%\!filename!" >nul
    if !errorlevel! equ 0 (
        set /a copied+=1
        echo     ✓ 成功
    ) else (
        echo     ✗ 失败
    )
)

echo.
echo ========================================
echo 完成！
echo ========================================
echo 压缩成功: %success% / %count%
echo 复制成功: %copied% / %success%
echo.
echo 临时文件保存在: %TEMP_DIR%
echo 项目视频目录: %TARGET_DIR%
echo.
echo 下一步：
echo 1. 验证视频文件
echo 2. 运行 hvigorw clean
echo 3. 运行 hvigorw assembleHap
echo 4. 测试应用
echo.
pause
