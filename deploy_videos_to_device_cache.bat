@echo off
chcp 65001 >nul
echo ========================================
echo 📱 部署视频文件到设备缓存目录
echo ========================================
echo.

REM 检查本地视频目录
if not exist "hanzileyuan_videos" (
    echo ❌ 本地视频目录不存在: hanzileyuan_videos
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
    echo 请在 DevEco Studio 的终端中运行此脚本
    pause
    exit /b 1
)

REM 检查设备连接
echo 🔍 检查设备连接...
hdc list targets >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 未检测到设备
    pause
    exit /b 1
)

echo ✅ 设备已连接
echo.

REM 获取应用的cacheDir路径
echo 📁 获取应用缓存目录...
REM 注意：需要先安装应用才能获取cacheDir
REM cacheDir路径通常为: /data/storage/el2/base/cache/hanzileyuan_videos

REM 在设备上创建目录
echo 📁 在设备上创建缓存目录...
hdc shell "mkdir -p /data/storage/el2/base/cache/hanzileyuan_videos"
echo ✅ 目录创建完成
echo.

REM 推送视频文件
echo 🚀 开始推送视频文件到设备...
echo 这可能需要几分钟，请耐心等待...
echo.

REM 逐个推送文件（更稳定）
set /a success=0
set /a failed=0

for %%f in (hanzileyuan_videos\*.mp4) do (
    echo 推送: %%~nxf
    hdc file send "%%f" "/data/storage/el2/base/cache/hanzileyuan_videos/%%~nxf" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set /a success+=1
    ) else (
        set /a failed+=1
        echo   ❌ 失败
    )
)

echo.
echo ========================================
echo ✅ 部署完成！
echo ========================================
echo.
echo 📊 统计结果:
echo   成功: %success% 个
echo   失败: %failed% 个
echo.
echo 📍 设备上的视频路径: /data/storage/el2/base/cache/hanzileyuan_videos
echo.
echo 📱 下一步操作：
echo 1. 重新编译应用（APK将非常小）
echo 2. 安装应用到设备
echo 3. 测试视频播放功能
echo.
pause
