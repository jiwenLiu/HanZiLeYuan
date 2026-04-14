import router from '@ohos.router'
import { CategoryData } from '../models/DataModels'
import { window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { soundEffectService } from '../services/SoundEffectService'

@Entry
@Component
struct ExplorePage {
  @State currentPage: number = 0
  @State categories1: CategoryData[] = [
    {
      id: 'animals',
      name: '动物篇',
      icon: '🐴',
      description: '学习动物相关汉字',
      courseCount: 2,
      gradient: ['#60A5FA', '#3B82F6']
    },
    {
      id: 'plants',
      name: '植物篇',
      icon: '🌱',
      description: '认识植物相关汉字',
      courseCount: 2,
      gradient: ['#34D399', '#059669']
    },
    {
      id: 'nature',
      name: '自然篇',
      icon: '☀️',
      description: '探索自然相关汉字',
      courseCount: 2,
      gradient: ['#FBBF24', '#F59E0B']
    }
  ]
  @State categories2: CategoryData[] = [
    {
      id: 'body',
      name: '人体篇',
      icon: '👨',
      description: '了解人体相关汉字',
      courseCount: 2,
      gradient: ['#F472B6', '#EC4899']
    },
    {
      id: 'daily',
      name: '日常篇',
      icon: '👕',
      description: '学习日常生活汉字',
      courseCount: 2,
      gradient: ['#A78BFA', '#8B5CF6']
    },
    {
      id: 'all',
      name: '全部课程',
      icon: '📚',
      description: '浏览所有视频课程',
      courseCount: 10,
      gradient: ['#9CA3AF', '#6B7280']
    }
  ]

  // 动画状态变量
  @State card1Offset: number = 0
  @State card2Offset: number = 0
  @State card3Offset: number = 0
  @State card4Offset: number = 0
  @State card5Offset: number = 0
  @State card6Offset: number = 0
  @State icon1Offset: number = 0
  @State icon2Offset: number = 0
  @State icon3Offset: number = 0
  @State icon4Offset: number = 0
  @State icon5Offset: number = 0
  @State icon6Offset: number = 0
  
  private animationTimer: number = -1

  async aboutToAppear() {
    console.info('✅ ExplorePage aboutToAppear - 启动动画')
    await this.setFullScreen()
    // 确保先清理旧的定时器
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
      this.animationTimer = -1
    }
    this.startSmoothAnimations()
  }
  
  aboutToDisappear() {
    console.info('✅ ExplorePage aboutToDisappear - 清理动画')
    // 清理动画定时器
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
      this.animationTimer = -1
    }
  }
  
  onPageShow() {
    console.info('✅ ExplorePage onPageShow - 页面显示')
    // 页面重新显示时，重启动画
    if (this.animationTimer === -1) {
      this.startSmoothAnimations()
    }
  }
  
  onPageHide() {
    console.info('✅ ExplorePage onPageHide - 页面隐藏')
    // 页面隐藏时，暂停动画以节省资源
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
      this.animationTimer = -1
    }
  }

  // 设置全屏沉浸式模式
  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      
      await mainWindow.setWindowLayoutFullScreen(true)
      await mainWindow.setWindowSystemBarEnable([])
      
      console.info('✅ ExplorePage 全屏模式已启用')
    } catch (err) {
      console.error('❌ ExplorePage 设置全屏失败:', JSON.stringify(err))
    }
  }

  // 流畅的连续动画（类似首页）
  startSmoothAnimations() {
    let time = 0
    this.animationTimer = setInterval(() => {
      time += 0.05
      
      // 6个卡片的浮动动画（使用不同的频率和相位）
      this.card1Offset = Math.sin(time * 0.8) * 15
      this.card2Offset = Math.sin(time * 0.8 + 0.5) * 15
      this.card3Offset = Math.sin(time * 0.8 + 1.0) * 15
      this.card4Offset = Math.sin(time * 0.8 + 1.5) * 15
      this.card5Offset = Math.sin(time * 0.8 + 2.0) * 15
      this.card6Offset = Math.sin(time * 0.8 + 2.5) * 15
      
      // 6个图标的浮动动画（频率稍快一点）
      this.icon1Offset = Math.sin(time * 1.2) * 10
      this.icon2Offset = Math.sin(time * 1.2 + 0.5) * 10
      this.icon3Offset = Math.sin(time * 1.2 + 1.0) * 10
      this.icon4Offset = Math.sin(time * 1.2 + 1.5) * 10
      this.icon5Offset = Math.sin(time * 1.2 + 2.0) * 10
      this.icon6Offset = Math.sin(time * 1.2 + 2.5) * 10
    }, 50) // 每50ms更新一次，和首页保持一致
  }

  @Builder CategoryCard(category: CategoryData, cardIndex: number, iconOffset: number) {
    Column({ space: 8 }) {
      // Emoji图标（带浮动动画，进一步缩小以显示课程数量）
      Text(category.icon)
        .fontSize(42)  // 48 → 42，再缩小13%
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 })  // 6 → 4
        .translate({ y: iconOffset })
        .animation({
          duration: 1500,
          curve: Curve.EaseInOut
        })

      // 课程标题
      Text(category.name)
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)

      // 课程描述
      Text(category.description)
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.8)')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 8 })

      // 底部信息栏
      Text(`${category.courseCount}节课`)
        .fontSize(11)
        .fontColor(Color.White)
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        .backgroundColor('rgba(255,255,255,0.3)')
        .borderRadius(10)
    }
    .width('30%')
    .aspectRatio(1)
    .padding(18)
    .borderRadius(16)
    .linearGradient({
      angle: 135,
      colors: [[category.gradient?.[0] || '#60a5fa', 0], [category.gradient?.[1] || '#3b82f6', 1]]
    })
    .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)' })
    .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
    .opacity(0.85)
    .backdropBlur(10)
    .translate({ 
      y: cardIndex === 0 ? this.card1Offset : 
         cardIndex === 1 ? this.card2Offset : 
         cardIndex === 2 ? this.card3Offset :
         cardIndex === 3 ? this.card4Offset :
         cardIndex === 4 ? this.card5Offset : this.card6Offset
    })
    .onClick(() => {
      soundEffectService.playClickSound();
      this.navigateToCategory(category.id)
    })
  }

  navigateToCategory(categoryId: string) {
    let url = ''
    switch (categoryId) {
      case 'animals':
        url = 'pages/categories/AnimalsPage'
        break
      case 'plants':
        url = 'pages/categories/PlantsPage'
        break
      case 'nature':
        url = 'pages/categories/NaturePage'
        break
      case 'body':
        url = 'pages/categories/BodyPage'
        break
      case 'daily':
        url = 'pages/categories/DailyPage'
        break
      case 'all':
        url = 'pages/WatchPage'
        break
    }
    if (url) {
      router.pushUrl({ url: url })
    }
  }

  previousPage() {
    if (this.currentPage > 0) {
      this.currentPage = 0
    }
  }

  nextPage() {
    if (this.currentPage < 1) {
      this.currentPage = 1
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
          colors: [['#a0522d', 0], ['#cd853f', 0.5], ['#daa520', 1]]
        })

      // 主内容
      Column() {
        // 上边距（弹性空白）- 减少权重，内容移到中间线
        Column().layoutWeight(0.15)

        // 提示文字（移到最上面）
        Text('选择你感兴趣的主题开始学习')
          .fontSize(16)
          .fontColor('rgba(255,255,255,0.9)')
          .textAlign(TextAlign.Center)
          .width('100%')
          .margin({ bottom: 12 })

        // 返回按钮 + 分页信息
        Row() {
          // 返回按钮（与个人中心样式一致）
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
          .onClick(() => {
            soundEffectService.playClickSound();
            router.replaceUrl({ url: 'pages/HomePage' })
          })

          Blank()

          // 分页信息
          Text(`${this.currentPage + 1}/2`)
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .backgroundColor('rgba(255,255,255,0.3)')
            .backdropBlur(10)
            .borderRadius(20)
            .border({ width: 1, color: 'rgba(255,255,255,0.5)' })
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.3)' })
            .textShadow({ radius: 5, color: 'rgba(0,0,0,0.3)' })

          Blank()

          // 占位保持居中
          Column()
            .width(68)
            .height(68)
        }
        .width('100%')
        .margin({ bottom: 24 })

        // 课程卡片区域
        Row({ space: 24 }) {
          // 左箭头（使用黄橙色图片资源，与返回按钮颜色一致）
          Image($r('app.media.ic_arrow_left'))
            .width(80)
            .height(80)
            .opacity(this.currentPage === 0 ? 0.3 : 1)
            .objectFit(ImageFit.Contain)  // 确保图片完整显示
            .interpolation(ImageInterpolation.High)  // 高质量渲染
            .border({ width: 0, color: Color.Transparent })  // 明确设置无边框
            .backgroundColor(Color.Transparent)  // 透明背景
            .shadow({ 
              radius: 30, 
              color: 'rgba(251, 191, 36, 0.6)',  // 黄橙色阴影，与返回按钮一致
              offsetX: 0,
              offsetY: 12
            })
            .onClick(() => {
              soundEffectService.playClickSound();
              this.previousPage()
            })

          // 卡片容器
          Stack() {
            // 第一页
            if (this.currentPage === 0) {
              Row({ space: 16 }) {
                this.CategoryCard(this.categories1[0], 0, this.icon1Offset)
                this.CategoryCard(this.categories1[1], 1, this.icon2Offset)
                this.CategoryCard(this.categories1[2], 2, this.icon3Offset)
              }
            }

            // 第二页
            if (this.currentPage === 1) {
              Row({ space: 16 }) {
                this.CategoryCard(this.categories2[0], 3, this.icon4Offset)
                this.CategoryCard(this.categories2[1], 4, this.icon5Offset)
                this.CategoryCard(this.categories2[2], 5, this.icon6Offset)
              }
            }
          }
          .layoutWeight(1)
          .gesture(
            PanGesture({ direction: PanDirection.Horizontal })
              .onActionEnd((event: GestureEvent) => {
                if (event.offsetX > 50) {
                  // 向右滑动，上一页
                  this.previousPage()
                } else if (event.offsetX < -50) {
                  // 向左滑动，下一页
                  this.nextPage()
                }
              })
          )

          // 右箭头（使用黄橙色图片资源，与返回按钮颜色一致）
          Image($r('app.media.ic_arrow_right'))
            .width(80)
            .height(80)
            .opacity(this.currentPage === 1 ? 0.3 : 1)
            .objectFit(ImageFit.Contain)  // 确保图片完整显示
            .interpolation(ImageInterpolation.High)  // 高质量渲染
            .border({ width: 0, color: Color.Transparent })  // 明确设置无边框
            .backgroundColor(Color.Transparent)  // 透明背景
            .shadow({ 
              radius: 30, 
              color: 'rgba(251, 191, 36, 0.6)',  // 黄橙色阴影，与返回按钮一致
              offsetX: 0,
              offsetY: 12
            })
            .onClick(() => {
              soundEffectService.playClickSound();
              this.nextPage()
            })
        }
        .width('100%')

        // 页码指示器
        Row({ space: 8 }) {
          Circle()
            .width(12)
            .height(12)
            .fill(this.currentPage === 0 ? Color.White : 'rgba(255,255,255,0.4)')
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.3)' })

          Circle()
            .width(12)
            .height(12)
            .fill(this.currentPage === 1 ? Color.White : 'rgba(255,255,255,0.4)')
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.3)' })
        }
        .margin({ top: 20 })

        // 下边距（弹性空白）- 增加权重，内容移到中间线
        Column().layoutWeight(1.35)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 40, right: 24, top: 20, bottom: 80 })
    }
    .width('100%')
    .height('100%')
  }
}












