@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo Bilibili视频处理和收集工具
echo ========================================
echo.

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

echo 步骤1: 处理视频文件
echo ========================================
echo 源目录: %SOURCE_DIR%
echo 处理程序: %SP_EXE%
echo 参数: 2
echo.

set /a process_count=0
set /a process_success=0

echo 开始处理...
echo.

REM 遍历所有子文件夹并处理
for /d %%d in ("%SOURCE_DIR%\*") do (
    set /a process_count+=1
    set "folder_name=%%~nxd"
    set "folder_path=%%d"
    
    echo [!process_count!] 处理: !folder_name!
    echo     文件夹: !folder_path!
    
    REM 进入子文件夹并调用sp.exe，自动输入2+回车
    cd /d "!folder_path!"
    echo 2| "%SP_EXE%" "!folder_path!"
    
    REM 检查是否生成了output.mp4
    if exist "!folder_path!\output.mp4" (
        set /a process_success+=1
        echo     ✓ 成功生成 output.mp4
    ) else (
        echo     ⚠ 未找到 output.mp4
    )
    
    REM 返回原目录
    cd /d "%~dp0"
)

echo.
echo 处理完成: %process_success%/%process_count%
echo.
echo 按任意键继续收集文件...
pause >nul

echo.
echo ========================================
echo 步骤2: 重命名生成的视频文件
echo ========================================
echo.

set /a rename_count=0
set /a rename_success=0

echo 正在重命名output.mp4文件...
echo.

REM 遍历所有子文件夹查找output.mp4并重命名
for /r "%SOURCE_DIR%" %%f in (output.mp4) do (
    set /a rename_count+=1
    set "file_path=%%f"
    set "folder_path=%%~dpf"
    
    REM 获取父文件夹名称
    for %%p in ("!folder_path:~0,-1!") do set "folder_name=%%~nxp"
    
    set "file_size=%%~zf"
    set /a size_mb=!file_size!/1024/1024
    
    echo [!rename_count!] !folder_name! (!size_mb! MB)
    
    REM 重命名为文件夹名称
    set "new_name=!folder_name!.mp4"
    set "new_path=!folder_path!!new_name!"
    
    REM 检查目标文件是否已存在
    if exist "!new_path!" (
        echo     ⚠ 已存在，跳过
    ) else (
        ren "%%f" "!new_name!" 2>nul
        if !errorlevel! equ 0 (
            set /a rename_success+=1
            echo     ✓ 已重命名
        ) else (
            echo     ✗ 失败
        )
    )
)

echo.
echo ========================================
echo 全部完成！
echo ========================================
echo.
echo 处理结果：
echo   处理文件夹: %process_count% 个
echo   处理成功: %process_success% 个
echo.
echo 重命名结果：
echo   找到视频: %rename_count% 个
echo   重命名成功: %rename_success% 个
echo.
echo 视频文件保存在各自的文件夹中
echo.
pause
