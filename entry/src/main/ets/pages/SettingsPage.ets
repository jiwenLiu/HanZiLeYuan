import { router, window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'

@Entry
@Component
struct SettingsPage {
  @State currentPageIndex: number = 0
  private swiperController: SwiperController = new SwiperController()
  
  // 设置页面数据
  private settingsPages: SettingsPageInfo[] = [
    {
      title: '基本设置',
      icon: '⚙️',
      items: [
        { label: '音量调节', value: '80%', type: 'slider' },
        { label: '自动播放', value: true, type: 'switch' },
        { label: '播放速度', value: '1.0x', type: 'selector' }
      ]
    },
    {
      title: '学习设置',
      icon: '📚',
      items: [
        { label: '每日目标', value: '15个', type: 'selector' },
        { label: '复习提醒', value: true, type: 'switch' },
        { label: '学习模式', value: '顺序', type: 'selector' }
      ]
    },
    {
      title: '显示设置',
      icon: '🎨',
      items: [
        { label: '字体大小', value: '标准', type: 'selector' },
        { label: '动画效果', value: true, type: 'switch' },
        { label: '夜间模式', value: false, type: 'switch' }
      ]
    },
    {
      title: '关于应用',
      icon: 'ℹ️',
      items: [
        { label: '版本号', value: 'v1.0.0', type: 'text' },
        { label: '开发者', value: '汉字乐园团队', type: 'text' },
        { label: '联系我们', value: 'support@hanzi.com', type: 'text' },
        { label: '隐私协议', value: '查看', type: 'link' }
      ]
    }
  ]

  async aboutToAppear() {
    await this.setFullScreen()
    await this.setLandscape()
  }

  // 设置全屏沉浸式模式
  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      
      await mainWindow.setWindowLayoutFullScreen(true)
      await mainWindow.setWindowSystemBarEnable([])
      
      console.info('✅ SettingsPage 全屏模式已启用')
    } catch (err) {
      console.error('❌ SettingsPage 设置全屏失败:', JSON.stringify(err))
    }
  }

  // 设置横屏模式
  async setLandscape() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      
      await mainWindow.setPreferredOrientation(window.Orientation.LANDSCAPE)
      
      console.info('✅ SettingsPage 横屏模式已启用')
    } catch (err) {
      console.error('❌ SettingsPage 设置横屏失败:', JSON.stringify(err))
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#667eea', 0.0],
            ['#764ba2', 0.5],
            ['#f093fb', 1.0]
          ]
        })

      // 主内容
      Column() {
        // 顶部导航栏
        Row() {
          // 返回按钮
          Stack() {
            Column()
              .width(50)
              .height(50)
              .borderRadius(25)
              .backgroundColor('rgba(255, 255, 255, 0.2)')
            
            Text('←')
              .fontSize(24)
              .fontColor(Color.White)
          }
          .onClick(() => {
            router.back()
          })

          Blank()

          // 页面指示器
          Row({ space: 8 }) {
            ForEach([0, 1, 2, 3], (index: number) => {
              Column()
                .width(this.currentPageIndex === index ? 24 : 8)
                .height(8)
                .borderRadius(4)
                .backgroundColor(this.currentPageIndex === index ? Color.White : 'rgba(255, 255, 255, 0.3)')
                .animation({
                  duration: 300,
                  curve: Curve.EaseInOut
                })
            })
          }

          Blank()

          // 占位（保持对称）
          Column()
            .width(50)
            .height(50)
        }
        .width('100%')
        .padding({ left: 32, right: 32, top: 20, bottom: 20 })

        // Swiper滑动翻页
        Swiper(this.swiperController) {
          ForEach(this.settingsPages, (page: SettingsPageInfo, pageIndex: number) => {
            this.SettingsPageContent(page)
          })
        }
        .width('100%')
        .layoutWeight(1)
        .indicator(false)
        .loop(false)
        .duration(300)
        .curve(Curve.EaseInOut)
        .onChange((index: number) => {
          this.currentPageIndex = index
        })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  SettingsPageContent(page: SettingsPageInfo) {
    Column() {
      // 页面标题
      Row() {
        Text(page.icon)
          .fontSize(48)
          .margin({ right: 16 })
        
        Text(page.title)
          .fontSize(32)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .margin({ bottom: 40 })

      // 设置项列表
      Column({ space: 16 }) {
        ForEach(page.items, (item: SettingsItem) => {
          this.SettingItemCard(item)
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 60, right: 60, top: 20, bottom: 40 })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  SettingItemCard(item: SettingsItem) {
    Row() {
      // 标签
      Text(item.label)
        .fontSize(18)
        .fontColor(Color.White)
        .layoutWeight(1)

      // 值/控件
      if (item.type === 'text') {
        Text(item.value as string)
          .fontSize(16)
          .fontColor('rgba(255, 255, 255, 0.7)')
      } else if (item.type === 'link') {
        Row() {
          Text(item.value as string)
            .fontSize(16)
            .fontColor('#4ade80')
            .margin({ right: 8 })
          
          Text('→')
            .fontSize(16)
            .fontColor('#4ade80')
        }
      } else if (item.type === 'switch') {
        Toggle({ type: ToggleType.Switch, isOn: item.value as boolean })
          .selectedColor('#4ade80')
          .switchPointColor(Color.White)
      } else if (item.type === 'selector') {
        Row() {
          Text(item.value as string)
            .fontSize(16)
            .fontColor('rgba(255, 255, 255, 0.9)')
            .margin({ right: 8 })
          
          Text('▼')
            .fontSize(12)
            .fontColor('rgba(255, 255, 255, 0.6)')
        }
      } else if (item.type === 'slider') {
        Row() {
          Slider({
            value: 80,
            min: 0,
            max: 100,
            step: 10,
            style: SliderStyle.OutSet
          })
            .width(120)
            .trackColor('rgba(255, 255, 255, 0.3)')
            .selectedColor(Color.White)
            .blockColor(Color.White)
          
          Text(item.value as string)
            .fontSize(16)
            .fontColor('rgba(255, 255, 255, 0.9)')
            .margin({ left: 12 })
        }
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 20, bottom: 20 })
    .borderRadius(16)
    .backgroundColor('rgba(255, 255, 255, 0.15)')
    .shadow({
      radius: 10,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      // 处理链接类型的点击
      if (item.type === 'link' && item.label === '隐私协议') {
        console.info('🔗 点击隐私协议')
        router.pushUrl({
          url: 'pages/PrivacyPolicyPage'
        })
      }
    })
  }
}

// 数据接口
interface SettingsPageInfo {
  title: string
  icon: string
  items: SettingsItem[]
}

interface SettingsItem {
  label: string
  value: string | boolean | number
  type: 'text' | 'switch' | 'selector' | 'slider' | 'link'
}


