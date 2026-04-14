@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo Bilibili视频批量处理工具（高级版）
echo ========================================
echo.

REM 设置路径
set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "SP_EXE=C:\Users\PC\Desktop\jihuo\sp.exe"
set "LOG_FILE=%SOURCE_DIR%\processing_log_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.txt"
set "LOG_FILE=%LOG_FILE: =0%"

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
echo 日志文件: %LOG_FILE%
echo.

REM 创建日志文件
echo Bilibili视频处理日志 > "%LOG_FILE%"
echo 开始时间: %date% %time% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo 开始处理...
echo.

REM 计数器
set /a count=0
set /a success=0
set /a failed=0

REM 记录开始时间
set "start_time=%time%"

REM 遍历所有子文件夹
for /d %%d in ("%SOURCE_DIR%\*") do (
    set /a count+=1
    set "folder_name=%%~nxd"
    set "folder_path=%%d"
    
    echo [!count!] 处理文件夹: !folder_name!
    echo     路径: !folder_path!
    
    REM 记录到日志
    echo [!count!] !folder_name! >> "%LOG_FILE%"
    echo     路径: !folder_path! >> "%LOG_FILE%"
    echo     时间: %time% >> "%LOG_FILE%"
    
    REM 检查文件夹是否为空
    dir /b "!folder_path!" 2>nul | findstr "^" >nul
    if errorlevel 1 (
        echo     ⚠ 文件夹为空，跳过
        echo     状态: 跳过（空文件夹） >> "%LOG_FILE%"
    ) else (
        REM 调用sp.exe处理该文件夹，自动输入参数2
        echo     正在调用: "%SP_EXE%" "!folder_path!" (自动输入: 2)
        echo 2 | "%SP_EXE%" "!folder_path!"
        
        if !errorlevel! equ 0 (
            set /a success+=1
            echo     ✓ 成功
            echo     状态: 成功 >> "%LOG_FILE%"
            
            REM 检查是否生成了mp4文件
            set "mp4_found=0"
            for %%f in ("!folder_path!\*.mp4") do (
                set "mp4_found=1"
                echo     生成文件: %%~nxf
                echo     生成文件: %%~nxf >> "%LOG_FILE%"
            )
            if !mp4_found! equ 0 (
                echo     ⚠ 未找到生成的mp4文件
                echo     警告: 未找到mp4文件 >> "%LOG_FILE%"
            )
        ) else (
            set /a failed+=1
            echo     ✗ 失败 (错误码: !errorlevel!)
            echo     状态: 失败 (错误码: !errorlevel!) >> "%LOG_FILE%"
        )
    )
    
    echo. >> "%LOG_FILE%"
    echo.
)

REM 记录结束时间
set "end_time=%time%"

echo ========================================
echo 处理完成！
echo ========================================
echo 总计: %count% 个文件夹
echo 成功: %success% 个
echo 失败: %failed% 个
echo.
echo 开始时间: %start_time%
echo 结束时间: %end_time%
echo.
echo 详细日志保存在: %LOG_FILE%
echo.

REM 记录总结到日志
echo ======================================== >> "%LOG_FILE%"
echo 处理总结 >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 总计: %count% 个文件夹 >> "%LOG_FILE%"
echo 成功: %success% 个 >> "%LOG_FILE%"
echo 失败: %failed% 个 >> "%LOG_FILE%"
echo 开始时间: %start_time% >> "%LOG_FILE%"
echo 结束时间: %end_time% >> "%LOG_FILE%"

pause
