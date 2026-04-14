@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo Bilibili视频批量处理工具（交互版）
echo ========================================
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

echo 源目录: %SOURCE_DIR%
echo 处理程序: %SP_EXE%
echo 参数: 2
echo.

REM 统计文件夹数量
set /a total_folders=0
for /d %%d in ("%SOURCE_DIR%\*") do set /a total_folders+=1

echo 找到 %total_folders% 个子文件夹
echo.
echo 处理模式：
echo 1. 自动模式（不询问，全部处理）
echo 2. 交互模式（每个文件夹询问是否处理）
echo 3. 预览模式（仅列出文件夹，不处理）
echo.
set /p mode="请选择模式 (1-3): "

if "%mode%"=="3" (
    echo.
    echo 预览模式 - 文件夹列表：
    echo ========================================
    set /a preview_count=0
    for /d %%d in ("%SOURCE_DIR%\*") do (
        set /a preview_count+=1
        echo [!preview_count!] %%~nxd
    )
    echo ========================================
    echo 总计: %preview_count% 个文件夹
    echo.
    pause
    exit /b
)

echo.
echo 开始处理...
echo.

REM 计数器
set /a count=0
set /a success=0
set /a failed=0
set /a skipped=0

REM 遍历所有子文件夹
for /d %%d in ("%SOURCE_DIR%\*") do (
    set /a count+=1
    set "folder_name=%%~nxd"
    set "folder_path=%%d"
    
    echo.
    echo ========================================
    echo [!count!/%total_folders%] !folder_name!
    echo ========================================
    echo 路径: !folder_path!
    
    REM 如果是交互模式，询问是否处理
    if "%mode%"=="2" (
        set /p process="是否处理此文件夹？(Y/N/Q-退出): "
        if /i "!process!"=="Q" (
            echo.
            echo 用户取消操作
            goto :summary
        )
        if /i not "!process!"=="Y" (
            echo 跳过
            set /a skipped+=1
            goto :continue
        )
    )
    
    echo 正在处理...
    
    REM 调用sp.exe处理该文件夹，自动输入参数2
    echo 2 | "%SP_EXE%" "!folder_path!"
    
    if !errorlevel! equ 0 (
        set /a success+=1
        echo ✓ 成功
        
        REM 显示生成的mp4文件
        for %%f in ("!folder_path!\*.mp4") do (
            echo   生成: %%~nxf
        )
    ) else (
        set /a failed+=1
        echo ✗ 失败 (错误码: !errorlevel!)
    )
    
    :continue
)

:summary
echo.
echo ========================================
echo 处理完成！
echo ========================================
echo 总计: %count% 个文件夹
echo 成功: %success% 个
echo 失败: %failed% 个
if "%mode%"=="2" echo 跳过: %skipped% 个
echo.
pause
