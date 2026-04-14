@echo off
chcp 65001 >nul
echo ========================================
echo 📦 移动视频文件回rawfile目录
echo ========================================
echo.

REM 设置源目录和目标目录
set "SOURCE_DIR=hanzileyuan_videos"
set "TARGET_DIR=entry\src\main\resources\rawfile\videos"

REM 检查源目录是否存在
if not exist "%SOURCE_DIR%" (
    echo ❌ 源目录不存在: %SOURCE_DIR%
    pause
    exit /b 1
)

REM 创建目标目录
if not exist "%TARGET_DIR%" (
    echo 📁 创建目标目录: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

REM 统计源文件
echo.
echo 📊 统计源文件...
for /f %%i in ('dir /b "%SOURCE_DIR%\*.mp4" 2^>nul ^| find /c /v ""') do set COUNT=%%i
echo 找到 %COUNT% 个视频文件
echo.

REM 移动文件
echo 🚚 开始移动文件...
echo.
move "%SOURCE_DIR%\*.mp4" "%TARGET_DIR%\" >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo ✅ 文件移动成功！
) else (
    echo ⚠️ 部分文件可能已存在或移动失败
)

echo.
echo 📊 验证结果...
dir "%TARGET_DIR%\*.mp4" /B
echo.

REM 统计目标文件
for /f %%i in ('dir /b "%TARGET_DIR%\*.mp4" 2^>nul ^| find /c /v ""') do set TARGET_COUNT=%%i
echo 目标目录现有 %TARGET_COUNT% 个视频文件

REM 统计文件大小
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
echo 2. 首次播放视频时会自动从rawfile复制到filesDir（懒加载）
echo 3. 后续播放直接使用filesDir中的缓存
echo.
pause
