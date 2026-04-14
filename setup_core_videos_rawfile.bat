@echo off
chcp 65001 >nul
echo ========================================
echo 📦 设置核心视频到rawfile（精简版）
echo ========================================
echo.

REM 目标目录
set "TARGET_DIR=entry\src\main\resources\rawfile\hanzileyuan_videos"

REM 创建目标目录
if not exist "%TARGET_DIR%" (
    echo 📁 创建目录: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

REM 只复制前15个核心视频（减小APK）
echo.
echo 🚚 复制15个核心视频...
echo.

copy "hanzileyuan_videos\第1课《马牛羊》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第1课
copy "hanzileyuan_videos\第2课《鸡狗猪猫》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第2课
copy "hanzileyuan_videos\第3课《鸟鱼虫万》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第3课
copy "hanzileyuan_videos\第4课《羽飞习翔》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第4课
copy "hanzileyuan_videos\第5课《木林森本末片》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第5课
copy "hanzileyuan_videos\第6课《树桑桃松柳》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第6课
copy "hanzileyuan_videos\第7课《米麦菜果瓜》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第7课
copy "hanzileyuan_videos\第8课《水泉川州洲》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第8课
copy "hanzileyuan_videos\第9课《河江湖海》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第9课
copy "hanzileyuan_videos\第10课《厂石原源》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第10课
copy "hanzileyuan_videos\第14课《日月晶星》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第14课
copy "hanzileyuan_videos\第15课《时早晚》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第15课
copy "hanzileyuan_videos\第16课《雨云雪》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第16课
copy "hanzileyuan_videos\第17课《春夏秋冬》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第17课
copy "hanzileyuan_videos\第18课《蓝青红黑白》.mp4" "%TARGET_DIR%\" >nul 2>&1 && echo ✅ 第18课

echo.
echo 📊 验证结果...
dir "%TARGET_DIR%\*.mp4" /B

echo.
echo 📏 统计大小...
powershell -Command "Get-ChildItem '%TARGET_DIR%' -Filter '*.mp4' | Measure-Object -Property Length -Sum | Select-Object Count, @{Name='TotalSizeMB';Expression={[math]::Round($_.Sum/1MB, 2)}}"

echo.
echo ========================================
echo ✅ 完成！
echo ========================================
echo.
echo 📍 已复制15个核心视频到rawfile
echo 💡 APK大小约: 600-800MB（可接受）
echo 🎯 其他33个视频可以后续在线下载
echo.
echo 📱 下一步：
echo    1. 重新编译应用
echo    2. 安装测试
echo    3. 核心视频可以直接播放
echo.
pause
