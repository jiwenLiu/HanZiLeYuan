@echo off
chcp 65001 >nul

set "SRC=D:\PC_test\Videos_Backup_Temp"
set "DST=D:\PC\HanZiLeYuan\entry\src\main\resources\rawfile\videos"

echo Restoring videos 10-22...

copy "%SRC%\第10课《厂石原源》.mp4" "%DST%\" /Y
copy "%SRC%\第11课《山丘阜阴阳》.mp4" "%DST%\" /Y
copy "%SRC%\第12课《田里界当男》.mp4" "%DST%\" /Y
copy "%SRC%\第13课《土地生金》.mp4" "%DST%\" /Y
copy "%SRC%\第14课《日月晶星》.mp4" "%DST%\" /Y
copy "%SRC%\第15课《时早晚》.mp4" "%DST%\" /Y
copy "%SRC%\第16课《雨云雪》.mp4" "%DST%\" /Y
copy "%SRC%\第17课《春夏秋冬》.mp4" "%DST%\" /Y
copy "%SRC%\第18课《蓝青红黑白》.mp4" "%DST%\" /Y
copy "%SRC%\第19课《上下内外》.mp4" "%DST%\" /Y
copy "%SRC%\第20课《东西南北中》.mp4" "%DST%\" /Y
copy "%SRC%\第21课《火炎灰赤燃灯》.mp4" "%DST%\" /Y
copy "%SRC%\第22课《光明亮的闪》.mp4" "%DST%\" /Y

echo Done!





