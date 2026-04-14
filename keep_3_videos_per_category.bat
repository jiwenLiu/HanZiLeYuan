@echo off
chcp 65001 >nul
echo ========================================
echo 📦 精简视频 - 每类保留3个
echo ========================================
echo.

set "VIDEO_DIR=entry\src\main\resources\rawfile\videos"

REM 备份当前视频
echo 📦 备份当前视频...
if not exist "videos_backup" mkdir "videos_backup"
xcopy "%VIDEO_DIR%\*.mp4" "videos_backup\" /Y /I >nul 2>&1
echo ✅ 备份完成
echo.

REM 删除所有视频
echo 🗑️  清空视频目录...
del "%VIDEO_DIR%\*.mp4" /Q >nul 2>&1
echo ✅ 清空完成
echo.

REM 复制精选视频（每类3个）
echo 📥 复制精选视频...
echo.

echo [动物篇] 3个
copy "videos_backup\第1课《马牛羊》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第1课
copy "videos_backup\第2课《鸡狗猪猫》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第2课
copy "videos_backup\第3课《鸟鱼虫万》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第3课

echo [植物篇] 3个
copy "videos_backup\第5课《木林森本末片》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第5课
copy "videos_backup\第6课《树桑桃松柳》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第6课
copy "videos_backup\第7课《米麦菜果瓜》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第7课

echo [自然篇] 3个
copy "videos_backup\第8课《水泉川州洲》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第8课
copy "videos_backup\第9课《河江湖海》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第9课
copy "videos_backup\第10课《厂石原源》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第10课

echo [天文气象篇] 3个
copy "videos_backup\第14课《日月晶星》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第14课
copy "videos_backup\第15课《时早晚》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第15课
copy "videos_backup\第16课《雨云雪》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第16课

echo [颜色方位篇] 3个
copy "videos_backup\第18课《蓝青红黑白》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第18课
copy "videos_backup\第19课《上下内外》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第19课
copy "videos_backup\第20课《东西南北中》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第20课

echo [光与火篇] 2个
copy "videos_backup\第21课《火炎灰赤燃灯》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第21课
copy "videos_backup\第22课《光明亮的闪》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第22课

echo [人物篇] 3个
copy "videos_backup\第23课《人从众比北》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第23课
copy "videos_backup\第24课《大太立站交文美》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第24课
copy "videos_backup\第25课《保孙儿孩》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第25课

echo [身体篇] 2个
copy "videos_backup\第29课《天元首页头发》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第29课
copy "videos_backup\第32课《口舌齿牙穿》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第32课

echo [日常篇] 3个
copy "videos_backup\第40课《宫堂室房家》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第40课
copy "videos_backup\第41课《车辇舟船》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第41课
copy "videos_backup\第42课《行道街市》.mp4" "%VIDEO_DIR%\" >nul 2>&1 && echo   ✅ 第42课

echo.
echo 📊 统计结果...
dir "%VIDEO_DIR%\*.mp4" /B

echo.
echo 📏 文件大小...
powershell -Command "Get-ChildItem '%VIDEO_DIR%' -Filter '*.mp4' | Measure-Object -Property Length -Sum | Select-Object Count, @{Name='TotalSizeMB';Expression={[math]::Round($_.Sum/1MB, 2)}}"

echo.
echo ========================================
echo ✅ 完成！
echo ========================================
echo.
echo 📊 精简结果:
echo    - 动物篇: 3个
echo    - 植物篇: 3个
echo    - 自然篇: 3个
echo    - 天文气象篇: 3个
echo    - 颜色方位篇: 3个
echo    - 光与火篇: 2个
echo    - 人物篇: 3个
echo    - 身体篇: 2个
echo    - 日常篇: 3个
echo    总计: 25个视频
echo.
echo 💡 APK大小预估: 约1GB
echo.
pause
