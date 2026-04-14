# 为所有页面添加音效支持的脚本

$pages = @(
    "entry/src/main/ets/pages/ListenPage.ets",
    "entry/src/main/ets/pages/QuizPage.ets",
    "entry/src/main/ets/pages/ProfilePage.ets",
    "entry/src/main/ets/pages/SettingsPage.ets",
    "entry/src/main/ets/pages/VideoPlayerPage.ets",
    "entry/src/main/ets/pages/PrivacyPolicyPage.ets",
    "entry/src/main/ets/pages/AchievementsPage.ets"
)

foreach ($page in $pages) {
    if (Test-Path $page) {
        $content = Get-Content $page -Raw -Encoding UTF8
        
        # 检查是否已经导入了soundEffectService
        if ($content -notmatch "soundEffectService") {
            Write-Host "处理文件: $page"
            
            # 在import语句后添加soundEffectService导入
            if ($content -match "import.*from '@kit") {
                $content = $content -replace "(import.*from '@kit[^']*')", "`$1`nimport { soundEffectService } from '../services/SoundEffectService'"
            }
            
            # 在所有onClick前添加音效调用
            $content = $content -replace "\.onClick\(\(\) => \{", ".onClick(() => {`n      soundEffectService.playClickSound();"
            
            # 保存文件
            $content | Out-File -FilePath $page -Encoding UTF8 -NoNewline
            Write-Host "✅ 已更新: $page"
        } else {
            Write-Host "⏭️ 跳过（已包含音效）: $page"
        }
    } else {
        Write-Host "❌ 文件不存在: $page"
    }
}

Write-Host "`n✅ 所有页面音效添加完成！"
