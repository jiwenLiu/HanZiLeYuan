@echo off
chcp 65001 >nul
echo 🎬 精简视频文件到10个核心视频...
echo.

REM 创建备份目录
if not exist "D:\PC_test\Videos_Full_Backup" mkdir "D:\PC_test\Videos_Full_Backup"

REM 备份
echo 📦 备份所有视频...
xcopy "entry\src\main\resources\rawfile\videos\*.mp4" "D:\PC_test\Videos_Full_Backup\" /Y /I
echo ✅ 备份完成
echo.

REM 删除所有视频
echo 🗑️  删除所有视频...
del "entry\src\main\resources\rawfile\videos\*.mp4" /Q
echo ✅ 删除完成
echo.

REM 复制10个核心视频
echo 📥 复制10个核心视频...
copy "D:\PC_test\Videos_Full_Backup\第1课《马牛羊》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第2课《鸡狗猪猫》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第5课《木林森本末片》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第6课《树桑桃松柳》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第8课《水泉川州洲》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第9课《河江湖海》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第23课《人从众比北》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第24课《大太立站交文美》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第40课《宫堂室房家》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
copy "D:\PC_test\Videos_Full_Backup\第41课《车辇舟船》.mp4" "entry\src\main\resources\rawfile\videos\" >nul
echo ✅ 复制完成
echo.

REM 验证
echo 📊 验证结果...
dir "entry\src\main\resources\rawfile\videos\*.mp4" /B
echo.

REM 统计大小
echo 📏 统计文件大小...
powershell -Command "Get-ChildItem 'entry\src\main\resources\rawfile\videos' -Filter '*.mp4' | Measure-Object -Property Length -Sum | Select-Object Count, @{Name='TotalSizeMB';Expression={[math]::Round($_.Sum/1MB, 2)}}"
echo.

echo ✅ 精简完成！现在可以重新编译了。
echo.
pause
