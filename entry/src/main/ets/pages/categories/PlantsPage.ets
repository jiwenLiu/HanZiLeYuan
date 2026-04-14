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
struct PlantsPage {
  @State currentPage: number = 0
  @State courses: CourseInfo[] = [
    { id: '5', title: '第5课', subtitle: '《木林森本末朱》', emoji: '🌳', duration: '12:00', status: 'not_started', category: 'plants', videoUrl: '' },
    { id: '6', title: '第6课', subtitle: '《米禾秧稻谷麦》', emoji: '🌾', duration: '11:15', status: 'not_started', category: 'plants', videoUrl: '' },
    { id: '7', title: '第7课', subtitle: '《瓜豆瓢瓣菜瓜》', emoji: '🥒', duration: '13:05', status: 'not_started', category: 'plants', videoUrl: '' }
  ]

  @State videoProgress: Map<string, VideoProgress> = new Map()
  private dataPreferences: preferences.Preferences | null = null

  @State card1Offset: number = 0
  @State card2Offset: number = 0
  @State card3Offset: number = 0
  @State emoji1Scale: number = 1
  @State emoji2Scale: number = 1
  @State emoji3Scale: number = 1

  private animationTimer: number = -1

  async aboutToAppear() {
    console.info('✅ PlantsPage aboutToAppear')
    await this.setFullScreen()
    await this.loadVideoProgress()
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
      this.animationTimer = -1
    }
    this.startSmoothAnimations()
  }

  aboutToDisappear() {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
      this.animationTimer = -1
    }
  }

  onPageShow() {
    if (this.animationTimer === -1) {
      this.startSmoothAnimations()
    }
  }

  onPageHide() {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
      this.animationTimer = -1
    }
  }

  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      await mainWindow.setWindowLayoutFullScreen(true)
      await mainWindow.setWindowSystemBarEnable([])
    } catch (err) {
      console.error('❌ PlantsPage 设置全屏失败:', JSON.stringify(err))
    }
  }

  async loadVideoProgress() {
    try {
      const context = getContext(this) as common.UIAbilityContext
      this.dataPreferences = await preferences.getPreferences(context, 'video_progress')

      for (let course of this.courses) {
        const key = `video_progress_${course.id}`
        const progressJson = await this.dataPreferences.get(key, '{}') as string
        const progressData: VideoProgress = JSON.parse(progressJson) as VideoProgress

        if (progressData.videoId === course.id) {
          let stars = 0
          if (progressData.progress > 0 && progressData.progress < 50) stars = 1
          else if (progressData.progress >= 50 && progressData.progress < 100) stars = 2
          else if (progressData.progress >= 100) stars = 3

          course.status = progressData.status || 'not_started'
          this.videoProgress.set(course.id, {
            videoId: course.id,
            progress: progressData.progress || 0,
            status: progressData.status || 'not_started',
            currentTime: progressData.currentTime || 0,
            totalTime: progressData.totalTime || 0,
            stars: stars
          })
        }
      }
    } catch (err) {
      console.error('❌ 加载进度失败:', JSON.stringify(err))
    }
  }

  getStars(courseId: string): number {
    const progress = this.videoProgress.get(courseId)
    return progress ? progress.stars : 0
  }

  getPlayedTime(courseId: string): string {
    const progress = this.videoProgress.get(courseId)
    if (!progress || progress.currentTime === 0) return '00:00'
    const mins = Math.floor(progress.currentTime / 60)
    const secs = Math.floor(progress.currentTime % 60)
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  startSmoothAnimations() {
    let time = 0
    this.animationTimer = setInterval(() => {
      time += 0.05
      this.card1Offset = Math.sin(time * 0.8) * 15
      this.card2Offset = Math.sin(time * 0.8 + 0.5) * 15
      this.card3Offset = Math.sin(time * 0.8 + 1.0) * 15
      this.emoji1Scale = 1 + Math.sin(time * 1.2) * 0.1
      this.emoji2Scale = 1 + Math.sin(time * 1.2 + 0.5) * 0.1
      this.emoji3Scale = 1 + Math.sin(time * 1.2 + 1.0) * 0.1
    }, 50)
  }

  @Builder CourseCard(course: CourseInfo, cardIndex: number, emojiScale: number) {
    Column({ space: 6 }) {
      Text(course.emoji)
        .fontSize(48)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 })
        .scale({ x: emojiScale, y: emojiScale })

      Text(`${course.title}${course.subtitle}`)
        .fontSize(16)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Column({ space: 4 }) {
        Row() {
          Text(`⏱️ ${this.getPlayedTime(course.id)} / ${course.duration}`)
            .fontSize(10)
            .fontColor('rgba(255,255,255,0.9)')
        }
        .width('100%')

        Row() {
          Text(course.status === 'completed' ? '已完成' :
            course.status === 'learning' ? '学习中' : '未开始')
            .fontSize(10)
            .fontColor(Color.White)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(
              course.status === 'completed' ? 'rgba(34,197,94,0.6)' :
                course.status === 'learning' ? 'rgba(251,191,36,0.6)' : 'rgba(148,163,184,0.6)'
            )
            .borderRadius(4)

          Blank()

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
    .translate({
      y: cardIndex === 0 ? this.card1Offset :
        cardIndex === 1 ? this.card2Offset : this.card3Offset
    })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/VideoPlayerPage',
        params: { courseId: course.id, courseName: course.subtitle }
      })
    })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['#34D399', 0], ['#10B981', 0.5], ['#059669', 1]]
        })

      Column() {
        Column().layoutWeight(1)

        Row() {
          Stack() {
            Column()
              .width(56)
              .height(56)
              .borderRadius(28)
              .linearGradient({ angle: 135, colors: [['#fbbf24', 0], ['#f59e0b', 1]] })
              .shadow({ radius: 30, color: 'rgba(0,0,0,0.4)', offsetY: 2 })

            Text('←')
              .fontSize(38)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .onClick(() => { router.back() })

          Blank()

          Text('1/1')
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .backgroundColor('rgba(255,255,255,0.3)')
            .borderRadius(20)

          Blank()

          Column().width(56).height(56)
        }
        .width('100%')
        .margin({ bottom: 24 })

        Row({ space: 24 }) {
          // 左箭头（使用黄橙色图片资源，与WatchPage一致）
          Image($r('app.media.ic_arrow_left'))
            .width(80)
            .height(80)
            .opacity(0.3)
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

          Row({ space: 24 }) {
            ForEach(this.courses, (course: CourseInfo, index: number) => {
              this.CourseCard(course, index,
                index === 0 ? this.emoji1Scale : index === 1 ? this.emoji2Scale : this.emoji3Scale)
            }, (course: CourseInfo) => course.id)
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)

          // 右箭头（使用黄橙色图片资源，与WatchPage一致）
          Image($r('app.media.ic_arrow_right'))
            .width(80)
            .height(80)
            .opacity(0.3)
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
        }
        .width('100%')

        Row({ space: 8 }) {
          Circle()
            .width(12)
            .height(12)
            .fill(Color.White)
        }
        .margin({ top: 24 })

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



