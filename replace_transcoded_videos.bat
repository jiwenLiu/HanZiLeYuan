@echo off
chcp 65001 >nul
echo ========================================
echo 视频文件替换脚本
echo ========================================
echo.

REM 检查转码后的视频目录是否存在
if not exist "D:\PC_test\Videos_Converted" (
    echo ❌ 错误：找不到转码后的视频目录
    echo 请先使用格式工厂转码视频到 D:\PC_test\Videos_Converted
    echo.
    pause
    exit /b 1
)

echo 📂 检查转码后的视频文件...
dir "D:\PC_test\Videos_Converted\*.mp4" /b | find /c /v "" > temp_count.txt
set /p VIDEO_COUNT=<temp_count.txt
del temp_count.txt

if "%VIDEO_COUNT%"=="0" (
    echo ❌ 错误：转码目录中没有视频文件
    echo.
    pause
    exit /b 1
)

echo ✅ 找到 %VIDEO_COUNT% 个视频文件
echo.

echo 🗑️  删除旧视频文件...
del "entry\src\main\resources\rawfile\videos\*.mp4" /q 2>nul
echo ✅ 旧视频已删除
echo.

echo 📥 复制转码后的视频文件...
echo.

REM 动物篇
echo [1/5] 复制动物篇视频...
copy "D:\PC_test\Videos_Converted\第1课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第2课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第3课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
echo    ✅ 动物篇完成（3个视频）

REM 植物篇
echo [2/5] 复制植物篇视频...
copy "D:\PC_test\Videos_Converted\第5课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第6课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第7课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
echo    ✅ 植物篇完成（3个视频）

REM 自然篇
echo [3/5] 复制自然篇视频...
copy "D:\PC_test\Videos_Converted\第8课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第9课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第10课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
echo    ✅ 自然篇完成（3个视频）

REM 身体篇
echo [4/5] 复制身体篇视频...
copy "D:\PC_test\Videos_Converted\第23课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第24课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第25课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
echo    ✅ 身体篇完成（3个视频）

REM 日常篇
echo [5/5] 复制日常篇视频...
copy "D:\PC_test\Videos_Converted\第43课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第44课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
copy "D:\PC_test\Videos_Converted\第45课*.mp4" "entry\src\main\resources\rawfile\videos\" >nul 2>&1
echo    ✅ 日常篇完成（3个视频）

echo.
echo ========================================
echo 📊 验证复制结果
echo ========================================
echo.

dir "entry\src\main\resources\rawfile\videos\*.mp4" /b 2>nul | find /c /v "" > temp_count.txt
set /p COPIED_COUNT=<temp_count.txt
del temp_count.txt

if "%COPIED_COUNT%"=="15" (
    echo ✅ 成功！所有15个视频文件已复制
    echo.
    echo 📋 已复制的文件：
    dir "entry\src\main\resources\rawfile\videos\*.mp4" /b
) else (
    echo ⚠️  警告：只复制了 %COPIED_COUNT% 个文件，预期15个
    echo.
    echo 📋 已复制的文件：
    dir "entry\src\main\resources\rawfile\videos\*.mp4" /b
    echo.
    echo 请检查转码后的文件名是否正确
)

echo.
echo ========================================
echo 🎬 下一步操作
echo ========================================
echo.
echo 1. 编译项目：hvigorw assembleHap
echo 2. 安装到设备测试视频播放
echo.
pause










