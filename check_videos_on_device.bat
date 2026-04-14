@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo    📱 检查设备上的视频文件
echo ========================================
echo.

REM 检查hdc
where hdc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 找不到 hdc 命令
    echo 请在 DevEco Studio 的终端中运行
    pause
    exit /b 1
)

REM 检查设备
hdc list targets >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 未检测到设备
    pause
    exit /b 1
)

echo ✅ 设备已连接
echo.

REM 检查目录
echo 📁 检查视频目录...
hdc shell "ls /data/storage/el2/base/haps/entry/cache/hanzileyuan_videos" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 视频目录不存在
    echo.
    echo 请先运行: deploy_videos_simple.bat
    echo.
    pause
    exit /b 1
)

echo ✅ 视频目录存在
echo.

REM 列出视频文件
echo 📊 视频文件列表:
echo.
hdc shell "ls -lh /data/storage/el2/base/haps/entry/cache/hanzileyuan_videos/*.mp4" 2>nul | find ".mp4"

echo.
echo 📏 统计信息:
hdc shell "ls /data/storage/el2/base/haps/entry/cache/hanzileyuan_videos/*.mp4 2>/dev/null | wc -l" 2>nul

echo.
echo ========================================
echo ✅ 检查完成
echo ========================================
echo.
pause
