@echo off
chcp 65001 >nul
echo ========================================
echo 视频批量压缩工具
echo ========================================
echo.
echo 源目录: D:\PC_test\Videos
echo 目标格式: H.264 + AAC, 码率1.5M
echo 目标大小: 15-25MB
echo.
echo 开始处理...
echo.

REM 设置源目录和输出目录
set "SOURCE_DIR=D:\PC_test\Videos"
set "OUTPUT_DIR=D:\PC_test\Videos\compressed"

REM 创建输出目录
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
    echo 已创建输出目录: %OUTPUT_DIR%
    echo.
)

REM 计数器
set /a count=0
set /a success=0
set /a failed=0

REM 遍历所有mp4文件
for %%f in ("%SOURCE_DIR%\*.mp4") do (
    set /a count+=1
    echo [!count!] 正在处理: %%~nxf
    
    REM 压缩视频
    ffmpeg -i "%%f" -vcodec h264 -acodec aac -b:v 1.5M -b:a 128k -y "%OUTPUT_DIR%\%%~nxf" 2>nul
    
    if !errorlevel! equ 0 (
        set /a success+=1
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
