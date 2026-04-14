@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "SP_EXE=C:\Users\PC\Desktop\jihuo\sp.exe"

echo 开始处理...
echo.

set /a count=0

for /d %%d in ("%SOURCE_DIR%\*") do (
    set /a count+=1
    set "folder_path=%%d"
    
    echo [!count!] %%~nxd
    
    cd /d "!folder_path!"
    echo 2| "%SP_EXE%" "!folder_path!"
    
    cd /d "%~dp0"
)

echo.
echo 完成！处理了 %count% 个文件夹
pause
