@echo off
chcp 65001 >nul

set "SRC=D:\PC\HanZiLeYuan\entry\src\main\resources\rawfile\videos"
set "DST=D:\PC_test\Videos_Backup_Temp"

echo Moving more videos to backup (keep only 1 per category)...

:: 动物篇只保留第1课，备份2,3
move "%SRC%\第2课《鸡狗猪猫》.mp4" "%DST%\" 2>nul
move "%SRC%\第3课《鸟鱼虫万》.mp4" "%DST%\" 2>nul

:: 植物篇只保留第5课，备份6,7
move "%SRC%\第6课《树桑桃松柳》.mp4" "%DST%\" 2>nul
move "%SRC%\第7课《米麦菜果瓜》.mp4" "%DST%\" 2>nul

:: 自然篇只保留第8课，备份9,10
move "%SRC%\第9课《河江湖海》.mp4" "%DST%\" 2>nul
move "%SRC%\第10课《厂石原源》.mp4" "%DST%\" 2>nul

:: 身体篇只保留第23课，备份24,25
move "%SRC%\第24课《大太立站交文美》.mp4" "%DST%\" 2>nul
move "%SRC%\第25课《保孙儿孩》.mp4" "%DST%\" 2>nul

:: 日常篇只保留第40课，备份41,42
move "%SRC%\第41课《车辇舟船》.mp4" "%DST%\" 2>nul
move "%SRC%\第42课《行道街市》.mp4" "%DST%\" 2>nul

echo Done!





