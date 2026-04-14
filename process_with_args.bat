@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo Bilibili视频处理工具（命令行参数）
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "SP_EXE=C:\Users\PC\Desktop\jihuo\sp.exe"

REM 检查sp.exe是否存在
if not exist "%SP_EXE%" (
    echo 错误：找不到 sp.exe
    pause
    exit /b
)

echo 源目录: %SOURCE_DIR%
echo 处理程序: %SP_EXE%
echo 参数: 2
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
    
    REM 进入子文件夹
    cd /d "!folder_path!"
    
    REM 尝试不同的调用方式
    echo     尝试方式1: sp.exe 路径 2
    "%SP_EXE%" "!folder_path!" 2 >nul 2>&1
    
    if not exist "!folder_path!\output.mp4" (
        echo     尝试方式2: sp.exe 路径 /2
        "%SP_EXE%" "!folder_path!" /2 >nul 2>&1
    )
    
    if not exist "!folder_path!\output.mp4" (
        echo     尝试方式3: sp.exe 路径 -2
        "%SP_EXE%" "!folder_path!" -2 >nul 2>&1
    )
    
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

echo ========================================
echo 完成！
echo ========================================
echo 总计: %count% 个
echo 成功: %success% 个
echo.
pause
