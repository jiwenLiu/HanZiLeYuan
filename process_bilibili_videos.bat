@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo Bilibili视频批量处理工具
echo ========================================
echo.
echo 源目录: D:\BaiduNetdiskDownload\Videos\bilibili
echo 处理程序: C:\Users\PC\Desktop\jihuo\sp.exe
echo 参数: 2
echo.

REM 设置路径
set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "SP_EXE=C:\Users\PC\Desktop\jihuo\sp.exe"

REM 检查sp.exe是否存在
if not exist "%SP_EXE%" (
    echo 错误：找不到 sp.exe
    echo 路径: %SP_EXE%
    pause
    exit /b
)

REM 检查源目录是否存在
if not exist "%SOURCE_DIR%" (
    echo 错误：找不到源目录
    echo 路径: %SOURCE_DIR%
    pause
    exit /b
)

echo 开始处理...
echo.

REM 计数器
set /a count=0
set /a success=0
set /a failed=0

REM 遍历所有子文件夹
for /d %%d in ("%SOURCE_DIR%\*") do (
    set /a count+=1
    set "folder_name=%%~nxd"
    set "folder_path=%%d"
    
    echo [!count!] 处理文件夹: !folder_name!
    echo     路径: !folder_path!
    
    REM 进入子文件夹并调用sp.exe，自动输入参数2
    cd /d "!folder_path!"
    echo 2 | "%SP_EXE%" "!folder_path!"
    
    REM 检查是否生成了output.mp4
    if exist "!folder_path!\output.mp4" (
        set /a success+=1
        echo     ✓ 成功 - output.mp4已生成
    ) else (
        set /a failed+=1
        echo     ✗ 失败 - 未找到output.mp4
    )
    
    REM 返回原目录
    cd /d "%~dp0"
    echo.
)

echo ========================================
echo 处理完成！
echo ========================================
echo 总计: %count% 个文件夹
echo 成功: %success% 个
echo 失败: %failed% 个
echo.
pause
