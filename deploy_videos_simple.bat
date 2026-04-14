@echo off
chcp 65001 >nul
cls
echo.
echo ========================================
echo    📱 部署视频到设备 - 简化版
echo ========================================
echo.
echo 这个脚本会将48个视频推送到设备
echo 预计需要10-15分钟，请耐心等待
echo.
pause

REM 检查视频目录
if not exist "hanzileyuan_videos" (
    echo.
    echo ❌ 错误：找不到 hanzileyuan_videos 文件夹
    echo.
    pause
    exit /b 1
)

REM 统计视频数量
for /f %%i in ('dir /b "hanzileyuan_videos\*.mp4" 2^>nul ^| find /c /v ""') do set COUNT=%%i
echo.
echo 📊 找到 %COUNT% 个视频文件
echo.

REM 检查hdc
where hdc >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误：找不到 hdc 命令
    echo.
    echo 解决方法：
    echo 1. 在 DevEco Studio 的终端中运行此脚本
    echo 2. 或者将 HarmonyOS SDK 的 toolchains 目录添加到 PATH
    echo.
    pause
    exit /b 1
)

REM 检查设备
echo 🔍 检查设备连接...
hdc list targets >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误：未检测到设备
    echo.
    echo 解决方法：
    echo 1. 连接设备到电脑
    echo 2. 启用 USB 调试
    echo 3. 信任此电脑
    echo.
    pause
    exit /b 1
)

echo ✅ 设备已连接
echo.

REM 创建目录
echo 📁 在设备上创建目录...
hdc shell "mkdir -p /data/storage/el2/base/haps/entry/cache/hanzileyuan_videos" 2>nul
echo ✅ 目录创建完成
echo.

REM 推送视频
echo 🚀 开始推送视频文件...
echo.
echo 进度：

set /a total=%COUNT%
set /a current=0

for %%f in (hanzileyuan_videos\*.mp4) do (
    set /a current+=1
    set /a percent=current*100/total
    
    echo [!percent!%%] 推送: %%~nxf
    hdc file send "%%f" "/data/storage/el2/base/haps/entry/cache/hanzileyuan_videos/%%~nxf" >nul 2>&1
    
    if !ERRORLEVEL! NEQ 0 (
        echo   ❌ 失败
    )
)

echo.
echo ========================================
echo ✅ 部署完成！
echo ========================================
echo.
echo 📍 设备上的视频路径:
echo    /data/storage/el2/base/haps/entry/cache/hanzileyuan_videos
echo.
echo 📱 下一步操作：
echo    1. 在 DevEco Studio 中点击 Run 按钮
echo    2. 等待应用安装（APK很小，约50MB）
echo    3. 打开应用，测试视频播放
echo.
echo 💡 提示：
echo    - APK不包含视频，所以很小
echo    - 视频在设备缓存目录，不占用应用空间
echo    - 支持懒加载，内存占用低
echo.
pause
