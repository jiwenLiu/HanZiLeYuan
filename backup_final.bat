@echo off
chcp 65001 >nul

set "SRC=D:\PC\HanZiLeYuan\entry\src\main\resources\rawfile\videos"
set "DST=D:\PC_test\Videos_Backup_Temp"

echo Final backup - keep only 5 videos (1 per category)...

:: 备份多余的
move "%SRC%\第4课《羽飞习翔》.mp4" "%DST%\" 2>nul
move "%SRC%\第11课《山丘阜阴阳》.mp4" "%DST%\" 2>nul
move "%SRC%\第26课《女好母每妇安》.mp4" "%DST%\" 2>nul
move "%SRC%\第43课《衣裘表里被》.mp4" "%DST%\" 2>nul

echo Done!





