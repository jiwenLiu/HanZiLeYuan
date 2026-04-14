@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo Bilibili视频处理工具（使用输入文件）
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "SP_EXE=C:\Users\PC\Desktop\jihuo\sp.exe"
set "INPUT_FILE=%TEMP%\sp_input.txt"

REM 检查sp.exe是否存在
if not exist "%SP_EXE%" (
    echo 错误：找不到 sp.exe
    pause
    exit /b
)

REM 检查源目录是否存在
if not exist "%SOURCE_DIR%" (
    echo 错误：找不到源目录
    pause
    exit /b
)

echo 源目录: %SOURCE_DIR%
echo 处理程序: %SP_EXE%
echo 自动输入: 2
echo.
echo 开始处理...
echo.

set /a count=0
set /a success=0

REM 遍历所有子文件夹
for /d %%d in ("%SOURCE_DIR%\*") do (
    set /a count+=1
    set "folder_name=%%~nxd"
    set "folder_path=%%d"
    
    echo [!count!] 处理: !folder_name!
    
    REM 创建输入文件
    echo 2> "%INPUT_FILE%"
    
    REM 进入子文件夹并调用sp.exe
    cd /d "!folder_path!"
    "%SP_EXE%" "!folder_path!" < "%INPUT_FILE%"
    
    REM 检查是否生成了output.mp4
    if exist "!folder_path!\output.mp4" (
        set /a success+=1
        echo     ✓ 成功
    ) else (
        echo     ⚠ 未找到output.mp4
    )
    
    cd /d "%~dp0"
    echo.
)

REM 删除临时文件
if exist "%INPUT_FILE%" del "%INPUT_FILE%"

echo ========================================
echo 完成！
echo ========================================
echo 总计: %count% 个
echo 成功: %success% 个
echo.
pause
