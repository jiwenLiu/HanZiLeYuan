import router from '@ohos.router'
import { CourseInfo } from '../../models/DataModels'
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'

interface VideoProgress {
  videoId: string
  progress: number
  status: string
  currentTime: number
  totalTime: number
  stars: number
}

@Entry
@Component
struct BodyPage {
  @State currentPage: number = 0
  @State courses: CourseInfo[] = [
    { id: '29', title: '第29课', subtitle: '《元元页页头首》', emoji: '👤', duration: '20:30', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '30', title: '第30课', subtitle: '《目眉睛眼睁》', emoji: '👁️', duration: '13:00', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '31', title: '第31课', subtitle: '《耳听聪聋》', emoji: '👂', duration: '9:55', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '32', title: '第32课', subtitle: '《鼻自臭嗅闻》', emoji: '👃', duration: '13:20', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '34', title: '第34课', subtitle: '《口舌齿牙唇吃》', emoji: '👄', duration: '15:50', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '35', title: '第35课', subtitle: '《自己身体》', emoji: '🧍', duration: '9:30', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '36', title: '第36课', subtitle: '《手拿打扫挥拍》', emoji: '✋', duration: '12:00', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '37', title: '第37课', subtitle: '《止步走趾跑路》', emoji: '🚶', duration: '10:35', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '38', title: '第38课', subtitle: '《肉皮毛发》', emoji: '💪', duration: '14:15', status: 'not_started', category: 'body', videoUrl: '' },
    { id: '39', title: '第39课', subtitle: '《血吃饱肚饿肥》', emoji: '🍽️', duration: '14:35', status: 'not_started', category: 'body', videoUrl: '' }
  ]
  
  @State videoProgress: Map<string, VideoProgress> = new Map()
  private dataPreferences: preferences.Preferences | null = null

  // 动画状态变量
  @State card1Offset: number = 0
  @State card2Offset: number = 0
  @State card3Offset: number = 0
  @State card4Offset: number = 0
  @State emoji1Scale: number = 1
  @State emoji2Scale: number = 1
  @State emoji3Scale: number = 1
  @State emoji4Scale: number = 1
  
  private animationTimer: number = -1

  async aboutToAppear() {
    console.info('✅ BodyPage aboutToAppear')
    await this.setFullScreen()
    await this.loadVideoProgress()
    // 确保先清理旧的定时器
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
      this.animationTimer = -1
    }
    this.startSmoothAnimations()
  }
  
  aboutToDisappear() {
    console.info('✅ BodyPage aboutToDisappear')
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
      this.animationTimer = -1
    }
  }
  
  onPageShow() {
    console.info('✅ BodyPage onPageShow')
    if (this.animationTimer === -1) {
      this.startSmoothAnimations()
    }
  }
  
  onPageHide() {
    console.info('✅ BodyPage onPageHide')
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
      
      console.info('✅ BodyPage 全屏模式已启用')
    } catch (err) {
      console.error('❌ BodyPage 设置全屏失败:', JSON.stringify(err))
    }
  }

  // 加载视频进度
  async loadVideoProgress() {
    try {
      const context = getContext(this) as common.UIAbilityContext
      this.dataPreferences = await preferences.getPreferences(context, 'video_progress')
      
      // ID映射：animal_1 -> 1, animal_2 -> 2, animal_3 -> 3
      const idMapping: Record<string, string> = {
        'animal_1': '29',
        'animal_2': '32',
        'animal_3': '3'
      }
      
      for (let course of this.courses) {
        const videoId = idMapping[course.id]
        if (videoId) {
          const key = `video_progress_${videoId}`
          const progressJson = await this.dataPreferences.get(key, '{}') as string
          const progressData: VideoProgress = JSON.parse(progressJson) as VideoProgress
          
          if (progressData.videoId === videoId) {
            // 计算星星数量
            let stars = 0
            if (progressData.progress > 0 && progressData.progress < 50) {
              stars = 1
            } else if (progressData.progress >= 50 && progressData.progress < 100) {
              stars = 2
            } else if (progressData.progress >= 100) {
              stars = 3
            }
            
            // 更新课程状态
            course.status = progressData.status || 'not_started'
            
            // 格式化播放时间
            const currentMins = Math.floor(progressData.currentTime / 60)
            const currentSecs = Math.floor(progressData.currentTime % 60)
            const playedTime = `${currentMins.toString().padStart(2, '0')}:${currentSecs.toString().padStart(2, '0')}`
            
            this.videoProgress.set(course.id, {
              videoId: videoId,
              progress: progressData.progress || 0,
              status: progressData.status || 'not_started',
              currentTime: progressData.currentTime || 0,
              totalTime: progressData.totalTime || 0,
              stars: stars
            })
            
            console.info(`✅ 加载进度 ${course.id}: ${progressData.progress}%, ${stars}颗星, 已播放${playedTime}`)
          }
        }
      }
    } catch (err) {
      console.error('❌ 加载进度失败:', JSON.stringify(err))
    }
  }

  // 获取星星数量
  getStars(courseId: string): number {
    const progress = this.videoProgress.get(courseId)
    return progress ? progress.stars : 0
  }

  // 获取播放时间
  getPlayedTime(courseId: string): string {
    const progress = this.videoProgress.get(courseId)
    if (!progress || progress.currentTime === 0) {
      return '00:00'
    }
    const mins = Math.floor(progress.currentTime / 60)
    const secs = Math.floor(progress.currentTime % 60)
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  // 流畅的连续动画（和ExplorePage一样）
  startSmoothAnimations() {
    let time = 0
    this.animationTimer = setInterval(() => {
      time += 0.05
      
      // 4个卡片的浮动动画
      this.card1Offset = Math.sin(time * 0.8) * 15
      this.card2Offset = Math.sin(time * 0.8 + 0.5) * 15
      this.card3Offset = Math.sin(time * 0.8 + 1.0) * 15
      this.card4Offset = Math.sin(time * 0.8 + 1.5) * 15
      
      // 4个Emoji的缩放动画
      this.emoji1Scale = 1 + Math.sin(time * 1.2) * 0.1
      this.emoji2Scale = 1 + Math.sin(time * 1.2 + 0.5) * 0.1
      this.emoji3Scale = 1 + Math.sin(time * 1.2 + 1.0) * 0.1
      this.emoji4Scale = 1 + Math.sin(time * 1.2 + 1.5) * 0.1
    }, 50) // 每50ms更新一次
  }

  @Builder CourseCard(course: CourseInfo, cardIndex: number, emojiScale: number) {
    Column({ space: 6 }) {
      // Emoji图标（带脉动动画）
      Text(course.emoji)
        .fontSize(48)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 })
        .scale({ x: emojiScale, y: emojiScale })
        .animation({
          duration: 1000,
          curve: Curve.EaseInOut
        })

      // 课程标题
      Text(`${course.title}${course.subtitle}`)
        .fontSize(16)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(20)

      // 课程描述
      Text(
        course.id === '29' ? '认识头部相关汉字' :
        course.id === '30' ? '学习眼睛相关汉字' :
        course.id === '31' ? '学习耳朵相关汉字' :
        course.id === '32' ? '学习鼻子相关汉字' :
        course.id === '34' ? '学习口腔相关汉字' :
        course.id === '35' ? '认识身体部位' :
        course.id === '36' ? '学习手部动作' :
        course.id === '37' ? '学习脚部动作' :
        course.id === '38' ? '认识皮肤毛发' :
        course.id === '39' ? '学习饮食相关汉字' :
        '学习人体相关汉字'
      )
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.8)')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 })

      // 底部信息栏
      Column({ space: 4 }) {
        // 播放时间和总时长
        Row() {
          Text(`⏱️ ${this.getPlayedTime(course.id)} / ${course.duration}`)
            .fontSize(10)
            .fontColor('rgba(255,255,255,0.9)')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')

        Row() {
          // 状态标签
          Text(course.status === 'completed' ? '已完成' :
            course.status === 'learning' ? '学习中' : '未开始')
            .fontSize(10)
            .fontColor(Color.White)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(
              course.status === 'completed' ? 'rgba(34,197,94,0.6)' :
                course.status === 'learning' ? 'rgba(251,191,36,0.6)' :
                  'rgba(148,163,184,0.6)'
            )
            .borderRadius(4)

          Blank()

          // 星级（根据实际进度）
          Row({ space: 2 }) {
            ForEach([1, 2, 3], (star: number) => {
              Text(star <= this.getStars(course.id) ? '⭐' : '☆')
                .fontSize(12)
                .fontColor(star <= this.getStars(course.id) ? '#fbbf24' : 'rgba(156,163,175,0.8)')
            })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
    }
    .width('30%')
    .aspectRatio(1)
    .padding(14)
    .borderRadius(16)
    .backgroundColor('rgba(255,255,255,0.2)')
    .border({ width: 1, color: 'rgba(255,255,255,0.3)' })
    .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)' })
    .opacity(0.85)
    .backdropBlur(15)
    .translate({ 
      y: cardIndex === 0 ? this.card1Offset : 
         cardIndex === 1 ? this.card2Offset : 
         cardIndex === 2 ? this.card3Offset : this.card4Offset 
    })
    .animation({
      duration: cardIndex === 0 ? 1500 : cardIndex === 1 ? 1750 : cardIndex === 2 ? 1600 : 1900,
      curve: Curve.EaseInOut
    })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/VideoPlayerPage',
        params: { courseId: course.id, courseName: course.subtitle }
      })
    })
  }

  // 获取当前页的课程（每页3个）
  getCurrentPageCourses(): CourseInfo[] {
    const startIndex = this.currentPage * 3
    return this.courses.slice(startIndex, startIndex + 3)
  }

  // 获取总页数
  getTotalPages(): number {
    return Math.ceil(this.courses.length / 3)
  }

  previousPage() {
    if (this.currentPage > 0) {
      this.currentPage--
    }
  }

  nextPage() {
    const totalPages = this.getTotalPages()
    if (this.currentPage < totalPages - 1) {
      this.currentPage++
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
          colors: [['#004d99', 0], ['#0066cc', 0.5], ['#0099ff', 1]]
        })

      // 主内容
      Column() {
        // 上边距（弹性空白）
        Column().layoutWeight(1)

        // 返回按钮 + 分页信息
        Row() {
          // 返回按钮
          Stack() {
            Column()
              .width(56)
              .height(56)
              .borderRadius(28)
              .linearGradient({
                angle: 135,
                colors: [['#fbbf24', 0], ['#f59e0b', 1]]
              })
              .shadow({ radius: 30, color: 'rgba(0,0,0,0.4)', offsetY: 2 })

            Text('←')
              .fontSize(38)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .onClick(() => {
            router.back()
          })

          Blank()

          // 分页信息
          Text(`${this.currentPage + 1}/${this.getTotalPages()}`)
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
            .width(56)
            .height(56)
        }
        .width('100%')
        .margin({ bottom: 24 })

        // 课程卡片区域
        Row({ space: 24 }) {
          // 左箭头（使用黄橙色图片资源，与WatchPage一致）
          Image($r('app.media.ic_arrow_left'))
            .width(80)
            .height(80)
            .opacity(this.currentPage > 0 ? 1 : 0.3)
            .objectFit(ImageFit.Contain)
            .interpolation(ImageInterpolation.High)
            .border({ width: 0, color: Color.Transparent })
            .backgroundColor(Color.Transparent)
            .shadow({ 
              radius: 30, 
              color: 'rgba(251, 191, 36, 0.6)',
              offsetX: 0,
              offsetY: 4
            })
            .onClick(() => {
              this.previousPage()
            })

          // 卡片容器 - 显示当前页的3个卡片
          Row({ space: 24 }) {
            ForEach(this.getCurrentPageCourses(), (course: CourseInfo, index: number) => {
              this.CourseCard(
                course,
                index,
                index === 0 ? this.emoji1Scale :
                  index === 1 ? this.emoji2Scale : this.emoji3Scale
              )
            }, (course: CourseInfo) => course.id)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
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

          // 右箭头（使用黄橙色图片资源，与WatchPage一致）
          Image($r('app.media.ic_arrow_right'))
            .width(80)
            .height(80)
            .opacity(this.currentPage < this.getTotalPages() - 1 ? 1 : 0.3)
            .objectFit(ImageFit.Contain)
            .interpolation(ImageInterpolation.High)
            .border({ width: 0, color: Color.Transparent })
            .backgroundColor(Color.Transparent)
            .shadow({ 
              radius: 30, 
              color: 'rgba(251, 191, 36, 0.6)',
              offsetX: 0,
              offsetY: 4
            })
            .onClick(() => {
              this.nextPage()
            })
        }
        .width('100%')

        // 页码指示器
        Row({ space: 8 }) {
          ForEach([0, 1], (pageIndex: number) => {
            Circle()
              .width(12)
              .height(12)
              .fill(this.currentPage === pageIndex ? Color.White : 'rgba(255,255,255,0.4)')
              .shadow({ radius: 10, color: 'rgba(0,0,0,0.3)' })
          }, (pageIndex: number) => pageIndex.toString())
        }
        .margin({ top: 24 })

        // 下边距（弹性空白）
        Column().layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 40, right: 24, top: 30, bottom: 80 })
    }
    .width('100%')
    .height('100%')
  }
}










