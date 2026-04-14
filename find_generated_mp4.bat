@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 查找生成的MP4文件
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"

echo 搜索目录: %SOURCE_DIR%
echo.
echo 正在搜索所有mp4文件...
echo.

set /a count=0

REM 遍历所有子文件夹查找mp4文件
for /r "%SOURCE_DIR%" %%f in (*.mp4) do (
    set /a count+=1
    set "file_path=%%f"
    set "file_name=%%~nxf"
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    
    echo [!count!] !file_name!
    echo     路径: !file_path!
    echo     大小: !size_mb! MB
    echo.
)

if %count% equ 0 (
    echo 未找到任何mp4文件
    echo.
    echo 可能的原因：
    echo 1. sp.exe 还未生成文件
    echo 2. sp.exe 生成的文件不是mp4格式
    echo 3. 文件保存在其他位置
    echo.
    echo 建议：
    echo 1. 检查 sp.exe 的输出日志
    echo 2. 手动运行一次 sp.exe 查看输出位置
    echo 3. 检查子文件夹中是否有其他格式的视频文件
) else (
    echo ========================================
    echo 找到 %count% 个mp4文件
    echo ========================================
)

echo.
pause
