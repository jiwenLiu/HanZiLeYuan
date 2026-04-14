@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 复制所有mp4文件并按列表重命名
echo ========================================
echo.

set "SOURCE_DIR=D:\BaiduNetdiskDownload\Videos\bilibili"
set "DEST_DIR=D:\BaiduNetdiskDownload\Videos\bilibili\all_videos"
set "NAME_LIST=D:\BaiduNetdiskDownload\Videos\bilibili\48个视频文件列表.txt"

REM 创建目标目录
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

REM 检查名称列表文件是否存在
if not exist "%NAME_LIST%" (
    echo 错误：找不到名称列表文件
    echo 路径: %NAME_LIST%
    pause
    exit /b
)

echo 源目录: %SOURCE_DIR%
echo 目标目录: %DEST_DIR%
echo 名称列表: %NAME_LIST%
echo.
echo 开始处理...
echo.

REM 读取名称列表到数组
set /a line_num=0
for /f "usebackq delims=" %%n in ("%NAME_LIST%") do (
    set /a line_num+=1
    set "name[!line_num!]=%%n"
)

echo 读取到 %line_num% 个文件名
echo.

REM 获取所有子文件夹并排序
set /a folder_count=0
for /f "delims=" %%d in ('dir /b /ad /on "%SOURCE_DIR%"') do (
    set /a folder_count+=1
    set "folder[!folder_count!]=%%d"
)

echo 找到 %folder_count% 个子文件夹
echo.

REM 遍历文件夹并复制所有mp4文件
set /a copied=0
for /l %%i in (1,1,%folder_count%) do (
    set "folder_name=!folder[%%i]!"
    set "new_name=!name[%%i]!"
    set "folder_path=%SOURCE_DIR%\!folder_name!"
    
    echo [%%i] !folder_name!
    
    REM 查找该文件夹中的所有mp4文件
    set "found_mp4=0"
    for %%f in ("!folder_path!\*.mp4") do (
        set "found_mp4=1"
        set "mp4_file=%%~nxf"
        
        if defined new_name (
            echo     找到: !mp4_file!
            echo     复制为: !new_name!
            copy "%%f" "%DEST_DIR%\!new_name!" >nul 2>&1
            if !errorlevel! equ 0 (
                set /a copied+=1
                echo     ✓ 成功
            ) else (
                echo     ✗ 失败
            )
            goto :next_folder
        ) else (
            echo     ⚠ 名称列表不足
        )
    )
    
    if !found_mp4! equ 0 (
        echo     ⚠ 未找到mp4文件
    )
    
    :next_folder
    echo.
)

echo ========================================
echo 完成！
echo ========================================
echo 处理: %folder_count% 个文件夹
echo 复制: %copied% 个文件
echo 目标目录: %DEST_DIR%
echo.
pause
