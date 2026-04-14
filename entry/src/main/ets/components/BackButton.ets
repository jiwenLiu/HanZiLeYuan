import { router } from '@kit.ArkUI'
import { soundEffectService } from '../services/SoundEffectService'

/**
 * 统一的返回按钮组件
 * 透明背景 + 白色箭头
 */
@Component
export struct BackButton {
  private onBack?: () => void  // 自定义返回逻辑

  build() {
    Text('←')
      .fontSize(36)
      .fontColor(Color.White)
      .fontWeight(FontWeight.Bold)
      .width(56)
      .height(56)
      .textAlign(TextAlign.Center)
      .borderRadius(28)
      .backgroundColor('rgba(255, 255, 255, 0.15)')
      .shadow({
        radius: 15,
        color: 'rgba(0, 0, 0, 0.2)',
        offsetX: 0,
        offsetY: 2
      })
      .onClick(() => {
        soundEffectService.playClickSound();
        if (this.onBack) {
          this.onBack()
        } else {
          router.back()
        }
      })
  }
}








