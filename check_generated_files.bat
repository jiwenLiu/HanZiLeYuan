@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 检查生成的文件
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"

echo 检查目录: %SOURCE_DIR%
echo.
echo 正在搜索所有视频文件（mp4, flv, mkv, avi, mov）...
echo.

set /a mp4_count=0
set /a flv_count=0
set /a mkv_count=0
set /a avi_count=0
set /a mov_count=0
set /a other_count=0

echo ========================================
echo MP4 文件：
echo ========================================
for /r "%SOURCE_DIR%" %%f in (*.mp4) do (
    set /a mp4_count+=1
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    echo [!mp4_count!] %%~nxf (!size_mb! MB)
    echo     %%~dpf
)
if %mp4_count% equ 0 echo （未找到）

echo.
echo ========================================
echo FLV 文件：
echo ========================================
for /r "%SOURCE_DIR%" %%f in (*.flv) do (
    set /a flv_count+=1
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    echo [!flv_count!] %%~nxf (!size_mb! MB)
    echo     %%~dpf
)
if %flv_count% equ 0 echo （未找到）

echo.
echo ========================================
echo MKV 文件：
echo ========================================
for /r "%SOURCE_DIR%" %%f in (*.mkv) do (
    set /a mkv_count+=1
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    echo [!mkv_count!] %%~nxf (!size_mb! MB)
    echo     %%~dpf
)
if %mkv_count% equ 0 echo （未找到）

echo.
echo ========================================
echo AVI 文件：
echo ========================================
for /r "%SOURCE_DIR%" %%f in (*.avi) do (
    set /a avi_count+=1
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    echo [!avi_count!] %%~nxf (!size_mb! MB)
    echo     %%~dpf
)
if %avi_count% equ 0 echo （未找到）

echo.
echo ========================================
echo MOV 文件：
echo ========================================
for /r "%SOURCE_DIR%" %%f in (*.mov) do (
    set /a mov_count+=1
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    echo [!mov_count!] %%~nxf (!size_mb! MB)
    echo     %%~dpf
)
if %mov_count% equ 0 echo （未找到）

echo.
echo ========================================
echo 统计结果：
echo ========================================
echo MP4: %mp4_count% 个
echo FLV: %flv_count% 个
echo MKV: %mkv_count% 个
echo AVI: %avi_count% 个
echo MOV: %mov_count% 个
echo.

set /a total=%mp4_count%+%flv_count%+%mkv_count%+%avi_count%+%mov_count%
echo 总计: %total% 个视频文件
echo.

if %total% equ 0 (
    echo ⚠️ 未找到任何视频文件！
    echo.
    echo 建议：
    echo 1. 检查 sp.exe 是否正确执行
    echo 2. 查看子文件夹中是否有其他格式的文件
    echo 3. 手动运行一次 sp.exe 查看输出
)

pause
