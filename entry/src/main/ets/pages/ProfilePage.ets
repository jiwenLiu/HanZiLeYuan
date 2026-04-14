import { router, window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import promptAction from '@ohos.promptAction'
import preferences from '@ohos.data.preferences'
import { antiAddictionService } from '../services/AntiAddictionService'
import { soundEffectService } from '../services/SoundEffectService'

@Entry
@Component
struct ProfilePage {
  @State userName: string = '汉字乐园'
  @State antiAddictionTime: number = 30
  @State showTimeDialog: boolean = false
  @State showSafetyKnowledge: boolean = false
  @State showPrivacyPolicy: boolean = false
  @State showAboutUs: boolean = false
  @State inputTime: string = '30'
  @State logoTranslateY: number = 0  // 头像浮动动画
  @State menuCardOffsets: number[] = [0, 0, 0, 0, 0]  // 五个菜单卡片的浮动偏移
  private dataPreferences: preferences.Preferences | null = null
  private logoTimer: number = -1  // 头像动画定时器
  private menuAnimTimer: number = -1  // 菜单卡片动画定时器

  async aboutToAppear() {
    await this.setFullScreen()
    await this.setLandscape()
    await this.initPreferences()
    await this.loadAntiAddictionTime()
    
    // 初始化防沉迷服务
    const context = getContext(this) as common.UIAbilityContext
    await antiAddictionService.initialize(context)
    this.antiAddictionTime = antiAddictionService.getLimitMinutes()
    this.inputTime = this.antiAddictionTime.toString()
    
    // 启动头像浮动动画（和启动页一样）
    this.logoTimer = setInterval(() => {
      const time = Date.now() / 1000
      this.logoTranslateY = Math.sin(time * 2) * 15
    }, 50)

    // 启动菜单卡片浮动动画（和首页一样）
    this.menuAnimTimer = setInterval(() => {
      const time = Date.now() / 1000
      for (let i = 0; i < 5; i++) {
        this.menuCardOffsets[i] = Math.sin(time * 1.5 + i * 0.5) * 12
      }
    }, 50)
  }

  // 初始化数据存储
  async initPreferences() {
    try {
      const context = getContext(this) as common.UIAbilityContext
      this.dataPreferences = await preferences.getPreferences(context, 'profile_data')
    } catch (err) {
      console.error('初始化存储失败:', JSON.stringify(err))
    }
  }

  // 加载防沉迷时间
  async loadAntiAddictionTime() {
    try {
      if (this.dataPreferences) {
        this.antiAddictionTime = await this.dataPreferences.get('antiAddictionTime', 30) as number
        this.inputTime = this.antiAddictionTime.toString()
      }
    } catch (err) {
      console.error('加载防沉迷时间失败:', JSON.stringify(err))
    }
  }

  // 保存防沉迷时间
  async saveAntiAddictionTime(time: number) {
    try {
      // 保存到本地preferences
      if (this.dataPreferences) {
        await this.dataPreferences.put('antiAddictionTime', time)
        await this.dataPreferences.flush()
        this.antiAddictionTime = time
      }
      
      // 保存到防沉迷服务
      await antiAddictionService.saveSettings(time)
      
      promptAction.showToast({ message: `防沉迷时长已设置为${time}分钟`, duration: 2000 })
    } catch (err) {
      console.error('保存防沉迷时间失败:', JSON.stringify(err))
      promptAction.showToast({ message: '设置失败', duration: 2000 })
    }
  }

  // 设置全屏沉浸式模式
  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      
      await mainWindow.setWindowLayoutFullScreen(true)
      await mainWindow.setWindowSystemBarEnable([])
      
      console.info('✅ ProfilePage 全屏模式已启用')
    } catch (err) {
      console.error('❌ ProfilePage 设置全屏失败:', JSON.stringify(err))
    }
  }

  // 设置横屏模式
  async setLandscape() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      
      await mainWindow.setPreferredOrientation(window.Orientation.LANDSCAPE)
      
      console.info('✅ ProfilePage 横屏模式已启用')
    } catch (err) {
      console.error('❌ ProfilePage 设置横屏失败:', JSON.stringify(err))
    }
  }

  aboutToDisappear() {
    // 清理动画定时器
    if (this.logoTimer !== -1) {
      clearInterval(this.logoTimer)
    }
    if (this.menuAnimTimer !== -1) {
      clearInterval(this.menuAnimTimer)
    }
  }

  // 显示投诉反馈弹窗（儿童应用必备功能）
  showReportDialog() {
    promptAction.showDialog({
      title: '反馈&投诉',
      message: '举报电话：15711279225\n举报邮箱：mashaohu05@chinasoftinc.com',
      buttons: [
        {
          text: '确定',
          color: '#007DFF'
        }
      ]
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [
            ['#667eea', 0.0],
            ['#764ba2', 0.5],
            ['#f093fb', 1.0]
          ]
        })

      // 返回按钮
      Stack() {
        Column()
          .width(56)
          .height(56)
          .borderRadius(28)
          .linearGradient({
            angle: 135,
            colors: [['#fbbf24', 0], ['#f97316', 1]]
          })
          .shadow({
            radius: 20,
            color: 'rgba(0, 0, 0, 0.3)',
            offsetX: 0,
            offsetY: 4
          })
        
        Text('←')
          .fontSize(28)
          .fontColor(Color.White)
      }
      .position({ x: 24, y: 56 })
      .zIndex(100)
      .onClick(() => {
        router.back()
      })

      // 主内容（单页显示所有内容）
      Column() {
        // 上边距（缩小）
        Blank().layoutWeight(0.3)

        // 个人信息区域
        Column({ space: 8 }) {
          // 头像（带浮动动画，尺寸缩小）
          Stack() {
            Column()
              .width(100)  // 128 → 100
              .height(100)
              .borderRadius(50)
              .linearGradient({
                angle: 135,
                colors: [
                  ['#fbbf24', 0.0],
                  ['#ea580c', 1.0]
                ]
              })
              .shadow({
                radius: 25,
                color: 'rgba(0, 0, 0, 0.3)',
                offsetX: 0,
                offsetY: 8
              })
            
            Text('汉')
              .fontSize(50)  // 64 → 50
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .translate({ y: this.logoTranslateY })

          // 用户名（字号缩小）
          Text(this.userName)
            .fontSize(32)  // 40 → 32
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 4 })

          // 家长提示语（缩小字号，两行显示）
          Text('亲爱的家长，好奇心是孩子最宝贵的财富。在鼓励孩子探索世界的同时，请务必重复强调现实生活中的水域安全规则，例如永不独自下水、在指定区域游泳等。让我们携手，培养出既勇敢又智慧的下一代探险家！')
            .fontSize(14)  // 20 → 14
            .fontColor('rgba(255, 255, 255, 0.85)')
            .textAlign(TextAlign.Center)
            .lineHeight(22)  // 32 → 22
            .width('85%')
            .maxLines(2)  // 限制为2行
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // 中间间距（缩小）
        Blank().layoutWeight(0.4)

        // 功能菜单区域（往上移动）
        Row({ space: 16 }) {  // 24 → 16，容纳5个菜单项
          // 安全知识
          this.MenuItem('🛡️', '安全知识', '', ['#10b981', '#059669'], 0, () => {
            this.showSafetyKnowledge = true
          })

          // 防沉迷设置
          this.MenuItem('⏰', '防沉迷设置', `当前：${this.antiAddictionTime}分钟`, ['#a855f7', '#9333ea'], 1, () => {
            this.showTimeDialog = true
          })

          // 隐私协议
          this.MenuItem('🔒', '隐私协议', '', ['#f97316', '#ea580c'], 2, () => {
            console.info('🔗 跳转到隐私协议页面')
            router.pushUrl({
              url: 'pages/PrivacyPolicyPage'
            })
          })

          // 投诉反馈（儿童应用必备）
          this.MenuItem('📢', '投诉反馈', '', ['#3b82f6', '#2563eb'], 3, () => {
            this.showReportDialog()
          })

          // 关于我们
          this.MenuItem('ℹ️', '关于我们', '', ['#ec4899', '#db2777'], 4, () => {
            this.showAboutUs = true
          })
        }
        .width('100%')
        .padding({ left: 32, right: 32 })  // 40 → 32
        .justifyContent(FlexAlign.Center)

        // 下边距（缩小）
        Blank().layoutWeight(0.5)
      }
      .width('100%')
      .height('100%')

      // 防沉迷设置对话框
      if (this.showTimeDialog) {
        this.TimeSettingDialog()
      }

      // 安全知识对话框
      if (this.showSafetyKnowledge) {
        this.SafetyKnowledgeDialog()
      }

      // 隐私协议对话框
      if (this.showPrivacyPolicy) {
        this.PrivacyPolicyDialog()
      }

      // 关于我们对话框
      if (this.showAboutUs) {
        this.AboutUsDialog()
      }
    }
  }

  @Builder
  ProfileInfoPage() {
    Column() {
      // 顶部间距（再次减小，让内容更向上）
      Blank()
        .layoutWeight(0.2)

      // 头像和用户名
      Column({ space: 8 }) {
        // 头像（带浮动动画）- 使用启动页的"汉"字组件
        Stack() {
          Column()
            .width(120)
            .height(120)
            .borderRadius(60)
            .linearGradient({
              angle: 135,
              colors: [
                ['#fbbf24', 0.0],  // yellow-400
                ['#ea580c', 1.0]   // orange-600
              ]
            })
            .shadow({
              radius: 30,
              color: 'rgba(0, 0, 0, 0.3)',
              offsetX: 0,
              offsetY: 10
            })
          
          Text('汉')
            .fontSize(60)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .translate({ y: this.logoTranslateY })

        // 用户名（减小间距）
        Text(this.userName)
          .fontSize(36)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 4 })

        // 家长提示语（再次向上移动，减小间距）
        Text('亲爱的家长，好奇心是孩子最宝贵的财富。在鼓励孩子探索世界的同时，请务必重复强调现实生活中的水域安全规则，例如永不独自下水、在指定区域游泳等。让我们携手，培养出既勇敢又智慧的下一代探险家！')
          .fontSize(16)
          .fontColor('rgba(255, 255, 255, 0.9)')
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .width('88%')
          .margin({ top: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 底部间距（增大以确保内容不被截断）
      Blank()
        .layoutWeight(1.5)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 60, right: 60, top: 0, bottom: 100 })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  MenuPage() {
    Column() {
      // 功能菜单
      Row({ space: 32 }) {
        // 安全知识
        this.MenuItem('🛡️', '安全知识', '', ['#10b981', '#059669'], 0, () => {
          this.showSafetyKnowledge = true
        })

        // 防沉迷设置
        this.MenuItem('⏰', '防沉迷设置', `当前：${this.antiAddictionTime}分钟`, ['#a855f7', '#9333ea'], 1, () => {
          this.showTimeDialog = true
        })

        // 隐私协议
        this.MenuItem('🔒', '隐私协议', '', ['#f97316', '#ea580c'], 2, () => {
          console.info('🔗 跳转到隐私协议页面')
          router.pushUrl({
            url: 'pages/PrivacyPolicyPage'
          })
        })

        // 投诉反馈（儿童应用必备）
        this.MenuItem('📢', '投诉反馈', '', ['#3b82f6', '#2563eb'], 3, () => {
          this.showReportDialog()
        })

        // 关于我们
        this.MenuItem('ℹ️', '关于我们', '', ['#ec4899', '#db2777'], 4, () => {
          this.showAboutUs = true
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 60, right: 60, top: 20, bottom: 40 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  MenuItem(icon: string, title: string, subtitle: string, gradientColors: string[], cardIndex: number, onClick: () => void) {
    Column({ space: 8 }) {  // 12 → 8
      // 图标背景（缩小）
      Stack() {
        Column()
          .width(64)  // 80 → 64
          .height(64)
          .borderRadius(16)  // 20 → 16
          .linearGradient({
            angle: 135,
            colors: [[gradientColors[0], 0], [gradientColors[1], 1]]
          })
          .shadow({
            radius: 12,  // 15 → 12
            color: 'rgba(0, 0, 0, 0.2)',
            offsetX: 0,
            offsetY: 3  // 4 → 3
          })
        
        Text(icon)
          .fontSize(32)  // 40 → 32
      }

      // 标题（缩小）
      Text(title)
        .fontSize(15)  // 18 → 15
        .fontColor('#1f2937')
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      // 副标题（如果有）
      if (subtitle) {
        Text(subtitle)
          .fontSize(12)  // 14 → 12
          .fontColor('#6b7280')
          .textAlign(TextAlign.Center)
      }
    }
    .width(120)  // 140 → 120，容纳5个菜单项
    .padding(10)  // 12 → 10
    .borderRadius(14)  // 16 → 14
    .linearGradient({
      angle: 135,
      colors: [['#fef3c7', 0], ['#fde68a', 1]]  // 主题黄色渐变，不要太白
    })
    .shadow({
      radius: 15,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 4
    })
    .translate({ y: this.menuCardOffsets[cardIndex] })  // 添加浮动动画
    .onClick(() => {
      onClick()
    })
    .animation({
      duration: 200,
      curve: Curve.EaseInOut
    })
  }

  @Builder
  TimeSettingDialog() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showTimeDialog = false
        })

      // 对话框内容
      Column({ space: 24 }) {
        // 标题
        Text('防沉迷设置')
          .fontSize(24)
          .fontColor('#1f2937')
          .fontWeight(FontWeight.Bold)

        // 说明
        Text('请设置使用时长（分钟）')
          .fontSize(16)
          .fontColor('#6b7280')

        // 输入框
        TextInput({ text: this.inputTime, placeholder: '请输入分钟数' })
          .width('100%')
          .height(50)
          .fontSize(18)
          .textAlign(TextAlign.Center)
          .borderRadius(12)
          .border({ width: 2, color: '#a855f7' })
          .backgroundColor(Color.White)
          .type(InputType.Number)
          .onChange((value: string) => {
            this.inputTime = value
          })

        // 按钮组
        Row({ space: 12 }) {
          // 取消按钮
          Button('取消')
            .width('48%')
            .height(50)
            .fontSize(18)
            .fontColor('#374151')
            .backgroundColor('#e5e7eb')
            .borderRadius(12)
            .onClick(() => {
              this.showTimeDialog = false
            })

          // 确定按钮
          Stack() {
            Column()
              .width('100%')
              .height('100%')
              .borderRadius(12)
              .linearGradient({
                angle: 90,
                colors: [['#a855f7', 0], ['#9333ea', 1]]
              })
              .shadow({
                radius: 15,
                color: 'rgba(168, 85, 247, 0.4)',
                offsetX: 0,
                offsetY: 4
              })

            Text('确定')
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width('48%')
          .height(50)
          .alignContent(Alignment.Center)
          .onClick(async () => {
            const time = parseInt(this.inputTime)
            if (time && time > 0) {
              await this.saveAntiAddictionTime(time)
              this.showTimeDialog = false
            } else {
              promptAction.showToast({ message: '请输入有效的分钟数', duration: 2000 })
            }
          })
        }
        .width('100%')
      }
      .width(400)
      .padding(30)
      .borderRadius(20)
      .backgroundColor(Color.White)
      .shadow({
        radius: 30,
        color: 'rgba(0, 0, 0, 0.3)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  SafetyKnowledgeDialog() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showSafetyKnowledge = false
        })

      // 对话框内容
      Column({ space: 20 }) {
        // 标题
        Row() {
          Text('🛡️')
            .fontSize(32)
            .margin({ right: 12 })
          
          Text('安全知识')
            .fontSize(28)
            .fontColor('#1f2937')
            .fontWeight(FontWeight.Bold)
        }

        // 内容区域（可滚动）
        Scroll() {
          Column({ space: 16 }) {
            // 第一条
            Column({ space: 8 }) {
              Text('1. 学习时间管理')
                .fontSize(20)
                .fontColor('#059669')
                .fontWeight(FontWeight.Bold)
              
              Text('建议每次学习时间不超过30分钟，每学习20分钟休息5-10分钟，保护视力健康。')
                .fontSize(16)
                .fontColor('#374151')
                .lineHeight(24)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 第二条
            Column({ space: 8 }) {
              Text('2. 正确的坐姿')
                .fontSize(20)
                .fontColor('#059669')
                .fontWeight(FontWeight.Bold)
              
              Text('保持正确坐姿，眼睛距离屏幕30-50厘米，避免长时间低头或歪头。')
                .fontSize(16)
                .fontColor('#374151')
                .lineHeight(24)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 第三条
            Column({ space: 8 }) {
              Text('3. 家长陪伴')
                .fontSize(20)
                .fontColor('#059669')
                .fontWeight(FontWeight.Bold)
              
              Text('建议家长陪同孩子一起学习，及时解答疑问，增进亲子互动。')
                .fontSize(16)
                .fontColor('#374151')
                .lineHeight(24)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // 第四条
            Column({ space: 8 }) {
              Text('4. 保护个人信息')
                .fontSize(20)
                .fontColor('#059669')
                .fontWeight(FontWeight.Bold)
              
              Text('不要在应用中透露个人隐私信息，如家庭住址、电话号码等。')
                .fontSize(16)
                .fontColor('#374151')
                .lineHeight(24)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .padding(20)
        }
        .width('100%')
        .height(300)
        .borderRadius(12)
        .backgroundColor('#f0fdf4')

        // 关闭按钮
        Button('我知道了')
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontColor(Color.White)
          .backgroundColor('#10b981')
          .borderRadius(12)
          .onClick(() => {
            this.showSafetyKnowledge = false
          })
      }
      .width(600)
      .padding(30)
      .borderRadius(20)
      .backgroundColor(Color.White)
      .shadow({
        radius: 30,
        color: 'rgba(0, 0, 0, 0.3)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  PrivacyPolicyDialog() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showPrivacyPolicy = false
        })

      // 对话框内容
      Column({ space: 20 }) {
        // 标题
        Row() {
          Text('🔒')
            .fontSize(32)
            .margin({ right: 12 })
          
          Text('隐私协议')
            .fontSize(28)
            .fontColor('#1f2937')
            .fontWeight(FontWeight.Bold)
        }

        // 内容区域（可滚动）
        Scroll() {
          Column({ space: 16 }) {
            Text('汉字乐园隐私保护声明')
              .fontSize(20)
              .fontColor('#ea580c')
              .fontWeight(FontWeight.Bold)

            Text('我们非常重视您和您孩子的隐私保护。本应用承诺：')
              .fontSize(16)
              .fontColor('#374151')
              .lineHeight(24)

            Column({ space: 12 }) {
              Text('• 不收集任何个人身份信息')
                .fontSize(16)
                .fontColor('#374151')
              
              Text('• 不使用任何第三方追踪工具')
                .fontSize(16)
                .fontColor('#374151')
              
              Text('• 所有学习数据仅存储在本地设备')
                .fontSize(16)
                .fontColor('#374151')
              
              Text('• 不会向任何第三方分享用户数据')
                .fontSize(16)
                .fontColor('#374151')
              
              Text('• 应用内无广告、无内购')
                .fontSize(16)
                .fontColor('#374151')
              
              Text('• 完全离线使用，无需网络连接')
                .fontSize(16)
                .fontColor('#374151')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Text('如有任何疑问，请联系我们：')
              .fontSize(16)
              .fontColor('#374151')
              .lineHeight(24)
              .margin({ top: 12 })

            Text('邮箱：support@hanziyuan.com')
              .fontSize(16)
              .fontColor('#ea580c')
              .fontWeight(FontWeight.Medium)
          }
          .padding(20)
        }
        .width('100%')
        .height(300)
        .borderRadius(12)
        .backgroundColor('#fff7ed')

        // 关闭按钮
        Button('我已阅读')
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontColor(Color.White)
          .backgroundColor('#f97316')
          .borderRadius(12)
          .onClick(() => {
            this.showPrivacyPolicy = false
          })
      }
      .width(600)
      .padding(30)
      .borderRadius(20)
      .backgroundColor(Color.White)
      .shadow({
        radius: 30,
        color: 'rgba(0, 0, 0, 0.3)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  AboutUsDialog() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showAboutUs = false
        })

      // 对话框内容
      Column({ space: 20 }) {
        // 标题和Logo
        Column({ space: 16 }) {
          // Logo
          Stack() {
            Column()
              .width(100)
              .height(100)
              .borderRadius(50)
              .linearGradient({
                angle: 135,
                colors: [
                  ['#fbbf24', 0.0],
                  ['#ea580c', 1.0]
                ]
              })
              .shadow({
                radius: 20,
                color: 'rgba(0, 0, 0, 0.3)',
                offsetX: 0,
                offsetY: 5
              })
            
            Text('汉')
              .fontSize(50)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }

          Text('汉字乐园')
            .fontSize(28)
            .fontColor('#1f2937')
            .fontWeight(FontWeight.Bold)

          Text('Chinese Character Garden')
            .fontSize(16)
            .fontColor('#6b7280')
        }

        // 版本信息
        Column({ space: 12 }) {
          Row() {
            Text('版本号：')
              .fontSize(16)
              .fontColor('#6b7280')
            Text('1.0.0')
              .fontSize(16)
              .fontColor('#ec4899')
              .fontWeight(FontWeight.Medium)
          }

          Row() {
            Text('更新日期：')
              .fontSize(16)
              .fontColor('#6b7280')
            Text('2025/12/2')
              .fontSize(16)
              .fontColor('#ec4899')
              .fontWeight(FontWeight.Medium)
          }
        }
        .width('100%')
        .padding(20)
        .borderRadius(12)
        .backgroundColor('#fdf2f8')

        // 应用介绍
        Column({ space: 12 }) {
          Text('关于应用')
            .fontSize(20)
            .fontColor('#ec4899')
            .fontWeight(FontWeight.Bold)

          Text('汉字乐园是一款专为儿童设计的汉字学习应用，通过生动有趣的动画视频、互动游戏和趣味问答，帮助孩子轻松掌握汉字知识，培养对中华文化的兴趣。')
            .fontSize(16)
            .fontColor('#374151')
            .lineHeight(24)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 联系方式
        Column({ space: 8 }) {
          Text('联系我们')
            .fontSize(18)
            .fontColor('#6b7280')
            .fontWeight(FontWeight.Medium)

          Text('📧 support@hanziyuan.com')
            .fontSize(14)
            .fontColor('#6b7280')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 关闭按钮
        Button('关闭')
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontColor(Color.White)
          .backgroundColor('#ec4899')
          .borderRadius(12)
          .onClick(() => {
            this.showAboutUs = false
          })
      }
      .width(600)
      .padding(30)
      .borderRadius(20)
      .backgroundColor(Color.White)
      .shadow({
        radius: 30,
        color: 'rgba(0, 0, 0, 0.3)',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }
}



