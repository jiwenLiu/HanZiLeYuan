@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 视频批量压缩工具（高级版）
echo ========================================
echo.
echo 源目录: D:\PC_test\Videos
echo 目标格式: H.264 + AAC
echo 码率: 视频1.5Mbps + 音频128kbps
echo 预期大小: 15-25MB
echo.

REM 设置源目录和输出目录
set "SOURCE_DIR=D:\PC_test\Videos"
set "OUTPUT_DIR=D:\PC_test\Videos\compressed"

REM 创建输出目录
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo 已创建输出目录: %OUTPUT_DIR%
)

REM 创建日志文件
set "LOG_FILE=%OUTPUT_DIR%\compression_log.txt"
echo 视频压缩日志 - %date% %time% > "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo 开始处理...
echo.

REM 计数器
set /a count=0
set /a success=0
set /a failed=0
set /a total_original_size=0
set /a total_compressed_size=0

REM 遍历所有mp4文件
for %%f in ("%SOURCE_DIR%\*.mp4") do (
    set /a count+=1
    set "filename=%%~nxf"
    set "original_size=%%~zf"
    
    echo [!count!] 处理: !filename!
    echo     原始大小: !original_size! 字节
    
    REM 记录到日志
    echo [!count!] !filename! >> "%LOG_FILE%"
    echo     原始大小: !original_size! 字节 >> "%LOG_FILE%"
    
    REM 压缩视频
    ffmpeg -i "%%f" -vcodec h264 -acodec aac -b:v 1.5M -b:a 128k -y "%OUTPUT_DIR%\!filename!" 2>nul
    
    if !errorlevel! equ 0 (
        set /a success+=1
        
        REM 获取压缩后的文件大小
        for %%c in ("%OUTPUT_DIR%\!filename!") do set "compressed_size=%%~zc"
        
        REM 计算压缩率
        set /a compression_ratio=!compressed_size!*100/!original_size!
        
        echo     压缩后: !compressed_size! 字节
        echo     压缩率: !compression_ratio!%%
        echo     ✓ 成功
        
        echo     压缩后: !compressed_size! 字节 >> "%LOG_FILE%"
        echo     压缩率: !compression_ratio!%% >> "%LOG_FILE%"
        echo     状态: 成功 >> "%LOG_FILE%"
        
        set /a total_original_size+=!original_size!
        set /a total_compressed_size+=!compressed_size!
    ) else (
        set /a failed+=1
        echo     ✗ 失败
        echo     状态: 失败 >> "%LOG_FILE%"
    )
    
    echo. >> "%LOG_FILE%"
    echo.
)

REM 计算总压缩率
if !total_original_size! gtr 0 (
    set /a total_compression_ratio=!total_compressed_size!*100/!total_original_size!
) else (
    set /a total_compression_ratio=0
)

echo ========================================
echo 处理完成！
echo ========================================
echo 总计: %count% 个文件
echo 成功: %success% 个
echo 失败: %failed% 个
echo.
echo 原始总大小: %total_original_size% 字节
echo 压缩后总大小: %total_compressed_size% 字节
echo 总压缩率: %total_compression_ratio%%%
echo.
echo 压缩后的文件保存在: %OUTPUT_DIR%
echo 详细日志保存在: %LOG_FILE%
echo.

REM 记录总结到日志
echo ======================================== >> "%LOG_FILE%"
echo 总结 >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo 总计: %count% 个文件 >> "%LOG_FILE%"
echo 成功: %success% 个 >> "%LOG_FILE%"
echo 失败: %failed% 个 >> "%LOG_FILE%"
echo 原始总大小: %total_original_size% 字节 >> "%LOG_FILE%"
echo 压缩后总大小: %total_compressed_size% 字节 >> "%LOG_FILE%"
echo 总压缩率: %total_compression_ratio%%% >> "%LOG_FILE%"

pause
