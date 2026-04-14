@echo off
chcp 65001 >nul
echo ========================================
echo 📱 部署视频文件到设备
echo ========================================
echo.

REM 检查本地视频目录
if not exist "hanzileyuan_videos" (
    echo ❌ 本地视频目录不存在: hanzileyuan_videos
    echo 请先运行 move_videos_to_external.bat
    pause
    exit /b 1
)

REM 统计本地文件
echo 📊 统计本地文件...
for /f %%i in ('dir /b "hanzileyuan_videos\*.mp4" 2^>nul ^| find /c /v ""') do set COUNT=%%i
echo 找到 %COUNT% 个视频文件
echo.

REM 检查hdc命令
where hdc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 找不到 hdc 命令
    echo 请确保 HarmonyOS SDK 的 toolchains 目录已添加到 PATH
    echo 或者在 DevEco Studio 的终端中运行此脚本
    pause
    exit /b 1
)

REM 检查设备连接
echo 🔍 检查设备连接...
hdc list targets >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 未检测到设备
    echo 请确保设备已连接并启用 USB 调试
    pause
    exit /b 1
)

echo ✅ 设备已连接
echo.

REM 在设备上创建目录
echo 📁 在设备上创建目录...
hdc shell mkdir -p /storage/emulated/0/hanzileyuan_videos
echo ✅ 目录创建完成
echo.

REM 推送视频文件
echo 🚀 开始推送视频文件到设备...
echo 这可能需要几分钟，请耐心等待...
echo.

hdc file send hanzileyuan_videos /storage/emulated/0/

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ 视频文件推送成功！
) else (
    echo.
    echo ❌ 视频文件推送失败
    pause
    exit /b 1
)

REM 验证
echo.
echo 📊 验证设备上的文件...
hdc shell ls -lh /storage/emulated/0/hanzileyuan_videos/*.mp4 | find ".mp4"

echo.
echo ========================================
echo ✅ 部署完成！
echo ========================================
echo.
echo 📍 设备上的视频路径: /storage/emulated/0/hanzileyuan_videos
echo.
echo 📱 下一步操作：
echo 1. 重新编译应用（APK将大幅减小）
echo 2. 安装应用到设备
echo 3. 测试视频播放功能
echo.
pause
