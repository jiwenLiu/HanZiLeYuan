@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 视频批量压缩工具（可选质量）
echo ========================================
echo.
echo 请选择压缩质量：
echo.
echo 1. 高质量 (2Mbps视频 + 128kbps音频, 目标: 25-30MB)
echo 2. 中等质量 (1.5Mbps视频 + 128kbps音频, 目标: 15-20MB) [推荐]
echo 3. 低质量 (1Mbps视频 + 96kbps音频, 目标: 10-15MB)
echo 4. 极低质量 (800kbps视频 + 96kbps音频, 目标: 8-12MB)
echo.
set /p quality="请输入选项 (1-4): "

REM 设置压缩参数
if "%quality%"=="1" (
    set "video_bitrate=2M"
    set "audio_bitrate=128k"
    set "quality_name=高质量"
) else if "%quality%"=="2" (
    set "video_bitrate=1.5M"
    set "audio_bitrate=128k"
    set "quality_name=中等质量"
) else if "%quality%"=="3" (
    set "video_bitrate=1M"
    set "audio_bitrate=96k"
    set "quality_name=低质量"
) else if "%quality%"=="4" (
    set "video_bitrate=800k"
    set "audio_bitrate=96k"
    set "quality_name=极低质量"
) else (
    echo 无效选项，使用默认中等质量
    set "video_bitrate=1.5M"
    set "audio_bitrate=128k"
    set "quality_name=中等质量"
)

echo.
echo 已选择: %quality_name%
echo 视频码率: %video_bitrate%
echo 音频码率: %audio_bitrate%
echo.

REM 设置源目录和输出目录
set "SOURCE_DIR=D:\PC_test\Videos"
set "OUTPUT_DIR=D:\PC_test\Videos\compressed_%quality_name%"

REM 创建输出目录
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo 已创建输出目录: %OUTPUT_DIR%
)

echo.
echo 开始处理...
echo.

REM 计数器
set /a count=0
set /a success=0
set /a failed=0

REM 遍历所有mp4文件
for %%f in ("%SOURCE_DIR%\*.mp4") do (
    set /a count+=1
    set "filename=%%~nxf"
    
    echo [!count!] 正在处理: !filename!
    
    REM 压缩视频
    ffmpeg -i "%%f" -vcodec h264 -acodec aac -b:v %video_bitrate% -b:a %audio_bitrate% -y "%OUTPUT_DIR%\!filename!" 2>nul
    
    if !errorlevel! equ 0 (
        set /a success+=1
        
        REM 显示文件大小
        for %%c in ("%OUTPUT_DIR%\!filename!") do (
            set "size=%%~zc"
            set /a size_mb=!size!/1024/1024
            echo     压缩后: !size_mb! MB
        )
        echo     ✓ 成功
    ) else (
        set /a failed+=1
        echo     ✗ 失败
    )
    echo.
)

echo ========================================
echo 处理完成！
echo ========================================
echo 总计: %count% 个文件
echo 成功: %success% 个
echo 失败: %failed% 个
echo.
echo 压缩后的文件保存在: %OUTPUT_DIR%
echo.
pause
