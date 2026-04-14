# 批量为onClick事件添加音效
# 此脚本会在每个.onClick(() => {后面添加soundEffectService.playClickSound();

$files = @(
    "entry/src/main/ets/pages/ListenPage.ets",
    "entry/src/main/ets/pages/QuizPage.ets",
    "entry/src/main/ets/pages/ProfilePage.ets",
    "entry/src/main/ets/pages/SettingsPage.ets",
    "entry/src/main/ets/pages/VideoPlayerPage.ets",
    "entry/src/main/ets/pages/PrivacyPolicyPage.ets"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "处理: $file"
        $content = Get-Content $file -Raw -Encoding UTF8
        
        # 替换所有onClick事件，在{后添加音效调用
        # 匹配模式: .onClick(() => {
        # 替换为: .onClick(() => {\n      soundEffectService.playClickSound();
        
        $pattern = '(\.onClick\(\(\) => \{)(\s*)'
        $replacement = '$1$2soundEffectService.playClickSound();$2'
        
        $newContent = $content -replace $pattern, $replacement
        
        if ($content -ne $newContent) {
            $newContent | Out-File -FilePath $file -Encoding UTF8 -NoNewline
            Write-Host "  ✅ 已更新"
        } else {
            Write-Host "  ⏭️ 无需更新"
        }
    }
}

Write-Host "`n✅ 批量添加完成！"
