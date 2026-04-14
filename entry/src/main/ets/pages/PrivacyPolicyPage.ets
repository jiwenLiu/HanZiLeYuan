import { router } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'

@Entry
@Component
struct PrivacyPolicyPage {
  private webController: webview.WebviewController = new webview.WebviewController()
  @State isLoading: boolean = true

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Button('← 返回', { type: ButtonType.Normal })
          .fontSize(16)
          .height(44)
          .padding({ left: 16, right: 16 })
          .backgroundColor(Color.Transparent)
          .fontColor('#0A59F7')
          .onClick(() => {
            router.back()
          })

        Blank()

        // 标题
        Text('隐私协议')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')

        Blank()

        // 占位，保持标题居中
        Row()
          .width(80)
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 16 })
      .backgroundColor('#FFFFFF')
      .borderWidth({ bottom: 0.5 })
      .borderColor('#E0E0E0')

      // Web组件加载HTML
      Stack() {
        Web({ src: $rawfile('html/privacy.html'), controller: this.webController })
          .width('100%')
          .height('100%')
          .backgroundColor('#FFFFFF')
          .onPageBegin(() => {
            this.isLoading = true
            console.info('📄 隐私协议页面开始加载')
          })
          .onPageEnd(() => {
            this.isLoading = false
            console.info('✅ 隐私协议页面加载完成')
          })
          .onErrorReceive((event) => {
            console.error('❌ 隐私协议页面加载失败:', JSON.stringify(event))
            this.isLoading = false
          })
          .domStorageAccess(true)
          .mixedMode(MixedMode.All)
          .cacheMode(CacheMode.Default)
          .javaScriptAccess(true)
          .fileAccess(true)

        // 加载指示器
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
              .color('#0A59F7')
            
            Text('加载中...')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}







