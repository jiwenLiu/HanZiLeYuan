@echo off
chcp 65001 >nul
echo ========================================
echo 📦 设置rawfile视频目录
echo ========================================
echo.

REM 检查源目录
if not exist "hanzileyuan_videos" (
    echo ❌ 源目录不存在: hanzileyuan_videos
    pause
    exit /b 1
)

REM 目标目录
set "TARGET_DIR=entry\src\main\resources\rawfile\hanzileyuan_videos"

REM 创建目标目录
if not exist "%TARGET_DIR%" (
    echo 📁 创建目标目录: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

REM 复制所有视频文件
echo.
echo 🚚 复制视频文件...
xcopy "hanzileyuan_videos\*.mp4" "%TARGET_DIR%\" /Y /I

if %ERRORLEVEL% EQU 0 (
    echo ✅ 视频文件复制成功！
) else (
    echo ❌ 复制失败
    pause
    exit /b 1
)

echo.
echo 📊 验证结果...
dir "%TARGET_DIR%\*.mp4" /B

echo.
echo 📏 统计文件大小...
powershell -Command "Get-ChildItem '%TARGET_DIR%' -Filter '*.mp4' | Measure-Object -Property Length -Sum | Select-Object Count, @{Name='TotalSizeMB';Expression={[math]::Round($_.Sum/1MB, 2)}}"

echo.
echo ========================================
echo ✅ 完成！
echo ========================================
echo.
echo 📍 视频文件位置: %CD%\%TARGET_DIR%
echo.
echo 📱 下一步操作：
echo 1. 重新编译应用
echo 2. 安装到设备
echo 3. 测试视频播放
echo.
echo ⚠️ 注意：APK会包含所有视频，大小约2GB
echo.
pause
