@echo off
chcp 65001 >nul
echo ========================================
echo 汉字乐园 - 问题检查和修复工具
echo ========================================
echo.

echo [1] 检查应用图标文件...
echo.
if exist "AppScope\resources\base\media\icon.png" (
    for %%F in ("AppScope\resources\base\media\icon.png") do (
        if %%~zF GTR 0 (
            echo ✓ AppScope图标文件存在，大小: %%~zF 字节
        ) else (
            echo ✗ AppScope图标文件为空！
        )
    )
) else (
    echo ✗ AppScope图标文件不存在！
)

if exist "entry\src\main\resources\base\media\icon.png" (
    for %%F in ("entry\src\main\resources\base\media\icon.png") do (
        if %%~zF GTR 0 (
            echo ✓ Entry图标文件存在，大小: %%~zF 字节
        ) else (
            echo ✗ Entry图标文件为空！
        )
    )
) else (
    echo ✗ Entry图标文件不存在！
)
echo.

echo [2] 检查音频文件...
echo.
set AUDIO_DIR=entry\src\main\resources\rawfile\audios
set AUDIO_FILES=ma.mp3 ji.mp3 niao.mp3 mu.mp3 shu.mp3 mi.mp3 shui.mp3 he.mp3 shi.mp3 ren.mp3 da.mp3 zi.mp3 yi.mp3 jin.mp3 bei.mp3
set EMPTY_COUNT=0
set MISSING_COUNT=0
set VALID_COUNT=0

for %%A in (%AUDIO_FILES%) do (
    if exist "%AUDIO_DIR%\%%A" (
        for %%F in ("%AUDIO_DIR%\%%A") do (
            if %%~zF GTR 0 (
                set /a VALID_COUNT+=1
                echo ✓ %%A - %%~zF 字节
            ) else (
                set /a EMPTY_COUNT+=1
                echo ✗ %%A - 文件为空！
            )
        )
    ) else (
        set /a MISSING_COUNT+=1
        echo ✗ %%A - 文件不存在！
    )
)
echo.

echo ========================================
echo 检查结果汇总
echo ========================================
echo 有效音频文件: %VALID_COUNT% / 15
echo 空音频文件: %EMPTY_COUNT%
echo 缺失音频文件: %MISSING_COUNT%
echo.

if %EMPTY_COUNT% GTR 0 (
    echo ⚠️  警告：发现 %EMPTY_COUNT% 个空音频文件！
    echo    听一听功能无法正常工作。
    echo.
)

if %MISSING_COUNT% GTR 0 (
    echo ⚠️  警告：缺失 %MISSING_COUNT% 个音频文件！
    echo.
)

if %VALID_COUNT% EQU 15 (
    echo ✓ 所有音频文件都正常！
    echo.
) else (
    echo ========================================
    echo 解决方案
    echo ========================================
    echo.
    echo 1. 使用在线TTS生成音频：
    echo    - 百度语音合成: https://ai.baidu.com/tech/speech/tts
    echo    - 讯飞语音合成: https://www.xfyun.cn/services/online_tts
    echo.
    echo 2. 将生成的音频文件复制到：
    echo    %AUDIO_DIR%\
    echo.
    echo 3. 确保文件名匹配：
    echo    ma.mp3, ji.mp3, niao.mp3, mu.mp3, shu.mp3, mi.mp3,
    echo    shui.mp3, he.mp3, shi.mp3, ren.mp3, da.mp3, zi.mp3,
    echo    yi.mp3, jin.mp3, bei.mp3
    echo.
)

echo ========================================
echo 应用图标修复步骤
echo ========================================
echo.
echo 如果修改图标后没有效果，请执行：
echo.
echo 1. 卸载应用：
echo    hdc uninstall com.chinasoft.tools.hanzileyuan
echo.
echo 2. 清理缓存：
echo    hvigorw clean
echo.
echo 3. 重新编译安装：
echo    hvigorw assembleHap
echo    hdc install entry\build\default\outputs\default\entry-default-signed.hap
echo.

pause









