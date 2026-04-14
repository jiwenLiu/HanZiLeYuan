import { router } from '@kit.ArkUI'
import { window } from '@kit.ArkUI'
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'

interface VideoInfo {
  id: string
  title: string
  subtitle: string
  emoji: string
  duration: string
}

interface VideoProgress {
  videoId: string
  progress: number
  status: string
  lastPlayTime: number
  currentTime: number
  totalTime: number
}

@Entry
@Component
struct VideoPlayerPage {
  @State currentVideoIndex: number = 0
  @State isPlaying: boolean = false
  @State videoSrc: string = 'videos/第1课《马牛羊鸡犬豕》.mp4'
  @State currentTime: number = 0
  @State totalTime: number = 0
  @State progress: number = 0
  @State videoStatus: string = 'not_started'
  @State stars: number = 0
  @State videoReady: boolean = false
  
  // 控制栏显示状态
  @State showControls: boolean = true
  private hideControlsTimer: number = -1
  private autoHideDelay: number = 3000
  
  private videoController: VideoController = new VideoController()
  private progressUpdateTimer: number = -1
  private dataPreferences: preferences.Preferences | null = null

  private videoList: VideoInfo[] = [
    { id: '1', title: '第1课', subtitle: '《马牛羊鸡犬豕》', emoji: '🐴', duration: '12:45' },
    { id: '2', title: '第2课', subtitle: '《鸟鹊鸠鸽鸦鹤》', emoji: '🐦', duration: '14:10' },
    { id: '3', title: '第3课', subtitle: '《燕雁鹰鹳》', emoji: '🦅', duration: '12:15' },
    { id: '4', title: '第4课', subtitle: '《鱼龟虾蟹》', emoji: '🐟', duration: '14:25' },
    { id: '5', title: '第5课', subtitle: '《木林森本末朱》', emoji: '🌳', duration: '12:00' },
    { id: '6', title: '第6课', subtitle: '《米禾秧稻谷麦》', emoji: '🌾', duration: '11:15' },
    { id: '7', title: '第7课', subtitle: '《瓜豆瓢瓣菜瓜》', emoji: '🥒', duration: '13:05' },
    { id: '8', title: '第8课', subtitle: '《水泉川州洲》', emoji: '💧', duration: '14:35' },
    { id: '9', title: '第9课', subtitle: '《江河湖海》', emoji: '🌊', duration: '8:20' },
    { id: '10', title: '第10课', subtitle: '《厂石原源》', emoji: '🏭', duration: '13:00' },
    { id: '11', title: '第11课', subtitle: '《山岩岭峰峡》', emoji: '⛰️', duration: '12:20' },
    { id: '12', title: '第12课', subtitle: '《田土圭壤尘》', emoji: '🌱', duration: '14:15' },
    { id: '13', title: '第13课', subtitle: '《日月星辰》', emoji: '☀️', duration: '9:15' },
    { id: '14', title: '第14课', subtitle: '《旦早晚昏星》', emoji: '⏰', duration: '10:20' },
    { id: '15', title: '第15课', subtitle: '《时光春夏》', emoji: '🌸', duration: '13:50' },
    { id: '16', title: '第16课', subtitle: '《秋冬雪霜》', emoji: '❄️', duration: '12:25' },
    { id: '17', title: '第17课', subtitle: '《风雨雷云冬》', emoji: '🌧️', duration: '12:45' },
    { id: '18', title: '第18课', subtitle: '《火炎灾炭灰》', emoji: '🔥', duration: '16:20' },
    { id: '19', title: '第19课', subtitle: '《赤橙黄绿青蓝》', emoji: '🎨', duration: '14:05' },
    { id: '20', title: '第20课', subtitle: '《紫白黑灰棕褐》', emoji: '🎨', duration: '16:00' },
    { id: '21', title: '第21课', subtitle: '《红黄灰赤黑炭燃》', emoji: '🔥', duration: '15:00' },
    { id: '22', title: '第22课', subtitle: '《金银铜铁锡铅》', emoji: '⚙️', duration: '12:55' },
    { id: '23', title: '第23课', subtitle: '《人从众比北》', emoji: '👨', duration: '12:50' },
    { id: '24', title: '第24课', subtitle: '《大太立站交文美》', emoji: '👨‍👩‍👧‍👦', duration: '11:35' },
    { id: '25', title: '第25课', subtitle: '《保孙儿孩》', emoji: '👶', duration: '11:55' },
    { id: '26', title: '第26课', subtitle: '《女子母每妇姐妹》', emoji: '👩', duration: '16:15' },
    { id: '27', title: '第27课', subtitle: '《父男兄弟叔舅》', emoji: '👨', duration: '22:20' },
    { id: '28', title: '第28课', subtitle: '《爸妈爷奶姥爷姥姥》', emoji: '👴', duration: '11:50' },
    { id: '29', title: '第29课', subtitle: '《元元页页头首》', emoji: '👤', duration: '20:30' },
    { id: '30', title: '第30课', subtitle: '《目眉睛眼睁》', emoji: '👁️', duration: '13:00' },
    { id: '31', title: '第31课', subtitle: '《耳听聪聋》', emoji: '👂', duration: '9:55' },
    { id: '32', title: '第32课', subtitle: '《鼻自臭嗅闻》', emoji: '👃', duration: '13:20' },
    { id: '33', title: '第33课', subtitle: '《户门扇窗开关》', emoji: '🚪', duration: '14:10' },
    { id: '34', title: '第34课', subtitle: '《口舌齿牙唇吃》', emoji: '👄', duration: '15:50' },
    { id: '35', title: '第35课', subtitle: '《自己身体》', emoji: '🧍', duration: '9:30' },
    { id: '36', title: '第36课', subtitle: '《手拿打扫挥拍》', emoji: '✋', duration: '12:00' },
    { id: '37', title: '第37课', subtitle: '《止步走趾跑路》', emoji: '🚶', duration: '10:35' },
    { id: '38', title: '第38课', subtitle: '《肉皮毛发》', emoji: '💪', duration: '14:15' },
    { id: '39', title: '第39课', subtitle: '《血吃饱肚饿肥》', emoji: '🍽️', duration: '14:35' },
    { id: '40', title: '第40课', subtitle: '《家宅室房屋》', emoji: '🏠', duration: '11:30' },
    { id: '41', title: '第41课', subtitle: '《门窗桌椅床》', emoji: '🪑', duration: '14:25' },
    { id: '42', title: '第42课', subtitle: '《刀匕剪刃》', emoji: '🔪', duration: '10:25' },
    { id: '44', title: '第44课', subtitle: '《巾布冠带》', emoji: '👔', duration: '12:25' },
    { id: '45', title: '第45课', subtitle: '《贝玉朋宝》', emoji: '💎', duration: '10:15' },
    { id: '46', title: '第46课', subtitle: '《网罟洗涤》', emoji: '🧺', duration: '12:10' },
    { id: '47', title: '第47课', subtitle: '《来去走进》', emoji: '🚶', duration: '12:45' },
    { id: '48', title: '第48课', subtitle: '《车轮轴辐》', emoji: '🚗', duration: '14:15' }
  ]

  async aboutToAppear() {
    console.info('🎬 视频播放页面加载')
    await this.initDataPreferences()
    await this.setFullScreen()

    const params = router.getParams() as Record<string, Object>
    if (params && params['courseId']) {
      const courseId = params['courseId'] as string
      console.info(`接收到courseId: ${courseId}`)
      const index = this.getCourseIndex(courseId)
      if (index !== -1) {
        this.currentVideoIndex = index
        console.info(`✅ 设置视频索引: ${index}`)
      }
    }

    // 立即加载视频路径
    this.loadVideo()
    
    await this.loadVideoProgress()
    this.startProgressUpdate()
    this.startAutoHideTimer()
  }

  async aboutToDisappear() {
    await this.saveVideoProgress()
    if (this.progressUpdateTimer !== -1) {
      clearInterval(this.progressUpdateTimer)
    }
    if (this.hideControlsTimer !== -1) {
      clearTimeout(this.hideControlsTimer)
    }
  }

  // 点击屏幕：暂停/播放，并显示控制栏
  handleScreenTap() {
    // 显示控制栏
    this.showControls = true
    
    // 切换播放/暂停
    if (this.isPlaying) {
      this.videoController.pause()
      // 暂停时不自动隐藏控制栏
    } else {
      this.videoController.start()
      // 播放时启动自动隐藏
      this.startAutoHideTimer()
    }
  }

  // 启动自动隐藏定时器
  startAutoHideTimer() {
    if (this.hideControlsTimer !== -1) {
      clearTimeout(this.hideControlsTimer)
    }
    this.hideControlsTimer = setTimeout(() => {
      if (this.isPlaying) {
        this.showControls = false
      }
    }, this.autoHideDelay)
  }

  async initDataPreferences() {
    try {
      const context = getContext(this) as common.UIAbilityContext
      this.dataPreferences = await preferences.getPreferences(context, 'video_progress')
      console.info('✅ 数据存储初始化成功')
    } catch (err) {
      console.error('❌ 数据存储初始化失败:', JSON.stringify(err))
    }
  }

  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      await mainWindow.setWindowLayoutFullScreen(true)
      await mainWindow.setWindowSystemBarEnable([])
      console.info('✅ VideoPlayerPage 全屏模式已启用')
    } catch (err) {
      console.error('❌ VideoPlayerPage 设置全屏失败:', JSON.stringify(err))
    }
  }

  async loadVideoProgress() {
    if (!this.dataPreferences) return
    try {
      const videoId = this.videoList[this.currentVideoIndex].id
      const key = `video_progress_${videoId}`
      const value = await this.dataPreferences.get(key, '')
      if (value) {
        const progressData: VideoProgress = JSON.parse(value as string)
        this.progress = progressData.progress
        this.videoStatus = progressData.status
        this.currentTime = progressData.currentTime
        this.totalTime = progressData.totalTime
        this.updateStars()
        console.info(`📖 加载进度: ${this.progress}%, 状态: ${this.videoStatus}`)
      }
    } catch (err) {
      console.error('❌ 加载进度失败:', JSON.stringify(err))
    }
  }

  async saveVideoProgress() {
    if (!this.dataPreferences) return
    try {
      const videoId = this.videoList[this.currentVideoIndex].id
      const key = `video_progress_${videoId}`
      const progressData: VideoProgress = {
        videoId: videoId,
        progress: this.progress,
        status: this.videoStatus,
        lastPlayTime: Date.now(),
        currentTime: this.currentTime,
        totalTime: this.totalTime
      }
      await this.dataPreferences.put(key, JSON.stringify(progressData))
      await this.dataPreferences.flush()
      console.info(`💾 保存进度: ${this.progress}%, 状态: ${this.videoStatus}`)
    } catch (err) {
      console.error('❌ 保存进度失败:', JSON.stringify(err))
    }
  }

  startProgressUpdate() {
    this.progressUpdateTimer = setInterval(() => {
      if (this.isPlaying && this.totalTime > 0) {
        this.progress = Math.floor((this.currentTime / this.totalTime) * 100)
        this.updateStatusAndStars()
      }
    }, 1000)
  }

  updateStatusAndStars() {
    if (this.progress === 0) {
      this.videoStatus = 'not_started'
      this.stars = 0
    } else if (this.progress < 50) {
      this.videoStatus = 'learning'
      this.stars = 1
    } else if (this.progress < 100) {
      this.videoStatus = 'learning'
      this.stars = 2
    } else {
      this.videoStatus = 'completed'
      this.stars = 3
    }
  }

  updateStars() {
    if (this.progress === 0) {
      this.stars = 0
    } else if (this.progress < 50) {
      this.stars = 1
    } else if (this.progress < 100) {
      this.stars = 2
    } else {
      this.stars = 3
    }
  }

  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = Math.floor(seconds % 60)
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
  }

  async playPrevious() {
    if (this.currentVideoIndex > 0) {
      console.info('🔙 切换到上一个视频')
      await this.saveVideoProgress()
      this.currentVideoIndex--
      this.loadVideo()
      await this.loadVideoProgress()
      this.isPlaying = false
      this.progress = 0
      setTimeout(() => {
        this.videoController.start()
      }, 500)
      this.startAutoHideTimer()
    }
  }

  async playNext() {
    if (this.currentVideoIndex < this.videoList.length - 1) {
      console.info('🔜 切换到下一个视频')
      await this.saveVideoProgress()
      this.currentVideoIndex++
      this.loadVideo()
      await this.loadVideoProgress()
      this.isPlaying = false
      this.progress = 0
      setTimeout(() => {
        this.videoController.start()
      }, 500)
      this.startAutoHideTimer()
    }
  }

  loadVideo() {
    const video = this.videoList[this.currentVideoIndex]
    this.videoSrc = `videos/第${video.id}课${video.subtitle}.mp4`
    this.videoReady = false
    console.info(`📹 加载视频: ${this.videoSrc}`)
  }

  getCourseIndex(courseId: string): number {
    const index = this.videoList.findIndex(video => video.id === courseId)
    return index
  }

  build() {
    Stack() {
      // 黑色背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')

      // 视频播放器（全屏，隐藏系统控制栏）
      Video({
        src: $rawfile(this.videoSrc),
        controller: this.videoController
      })
        .width('100%')
        .height('100%')
        .controls(false) // 隐藏系统控制栏（包括全屏按钮）
        .autoPlay(true)
        .objectFit(ImageFit.Cover) // 使用Cover填满屏幕，无黑边
        .backgroundColor('#000000')
        .onStart(() => {
          console.info('▶️ 视频开始播放')
          this.isPlaying = true
          this.videoReady = true
          this.startAutoHideTimer()
        })
        .onPause(() => {
          console.info('⏸️ 视频暂停')
          this.isPlaying = false
          this.showControls = true
        })
        .onFinish(() => {
          console.info('🏁 视频播放完成')
          this.isPlaying = false
          this.progress = 100
          this.videoStatus = 'completed'
          this.stars = 3
          this.saveVideoProgress()
          this.showControls = true
          
          if (this.currentVideoIndex < this.videoList.length - 1) {
            setTimeout(() => {
              this.playNext()
            }, 1000)
          }
        })
        .onError((error) => {
          // 忽略初始化时的临时错误，只记录真正的加载失败
          if (this.videoSrc && !this.videoReady) {
            console.warn(`⚠️ 视频初始化: ${JSON.stringify(error)}`)
          }
          this.showControls = true
        })
        .onUpdate((event) => {
          if (event && event.time !== undefined) {
            this.currentTime = event.time
          }
        })
        .onPrepared((event) => {
          if (event && event.duration !== undefined) {
            this.totalTime = event.duration
            this.videoReady = true
            console.info(`✅ 视频准备完成，时长: ${this.formatTime(event.duration)}`)
          }
        })

      // 播放/暂停图标（屏幕中央，仅在暂停时显示）
      if (!this.isPlaying) {
        Column() {
          Text('▶')
            .fontSize(80)
            .fontColor('rgba(255, 255, 255, 0.9)')
            .textShadow({ radius: 20, color: 'rgba(0,0,0,0.5)' })
        }
        .width(120)
        .height(120)
        .borderRadius(60)
        .backgroundColor('rgba(0, 0, 0, 0.6)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-50%', y: '-50%' })
        .zIndex(15)
        .onClick(() => {
          this.videoController.start()
        })
      }

      // 点击区域（用于暂停）
      if (this.isPlaying) {
        Column()
          .width('100%')
          .height('100%')
          .onClick(() => {
            this.handleScreenTap()
          })
      }

      // 顶部控制栏
      if (this.showControls) {
        Row() {
          // 返回按钮（圆形图标）
          Stack() {
            Column()
              .width(50)
              .height(50)
              .borderRadius(25)
              .backgroundColor('rgba(0, 0, 0, 0.6)')

            Text('←')
              .fontSize(28)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .onClick(() => {
            router.back()
          })

          Blank()

          // 视频标题
          Column() {
            Text(`${this.videoList[this.currentVideoIndex].title}`)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .textShadow({ radius: 4, color: 'rgba(0,0,0,0.8)' })
            
            Text(`${this.videoList[this.currentVideoIndex].subtitle}`)
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.8)')
              .textShadow({ radius: 4, color: 'rgba(0,0,0,0.8)' })
          }

          Blank()

          // 视频序号
          Text(`${this.currentVideoIndex + 1}/${this.videoList.length}`)
            .fontSize(14)
            .fontColor(Color.White)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('rgba(0, 0, 0, 0.5)')
            .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0.7)', 0], ['rgba(0,0,0,0)', 1]]
        })
        .position({ x: 0, y: 0 })
        .zIndex(20)
      }

      // 底部控制栏（只有上一个/下一个图标）
      if (this.showControls) {
        Row() {
          // 上一个图标
          Stack() {
            Column()
              .width(56)
              .height(56)
              .borderRadius(28)
              .backgroundColor(this.currentVideoIndex > 0 ? 'rgba(0, 0, 0, 0.6)' : 'rgba(0, 0, 0, 0.3)')

            Text('⏮')
              .fontSize(28)
              .fontColor(this.currentVideoIndex > 0 ? Color.White : 'rgba(255,255,255,0.4)')
          }
          .onClick(() => {
            if (this.currentVideoIndex > 0) {
              this.playPrevious()
            }
          })

          Blank()

          // 进度显示
          Column({ space: 4 }) {
            // 进度条
            Row() {
              Row()
                .width(`${this.totalTime > 0 ? (this.currentTime / this.totalTime) * 100 : 0}%`)
                .height('100%')
                .backgroundColor('#fbbf24')
                .borderRadius(3)
            }
            .width(200)
            .height(6)
            .backgroundColor('rgba(255,255,255,0.3)')
            .borderRadius(3)

            // 时间显示
            Text(`${this.formatTime(this.currentTime)} / ${this.formatTime(this.totalTime)}`)
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.9)')
          }

          Blank()

          // 下一个图标
          Stack() {
            Column()
              .width(56)
              .height(56)
              .borderRadius(28)
              .backgroundColor(this.currentVideoIndex < this.videoList.length - 1 ? 'rgba(0, 0, 0, 0.6)' : 'rgba(0, 0, 0, 0.3)')

            Text('⏭')
              .fontSize(28)
              .fontColor(this.currentVideoIndex < this.videoList.length - 1 ? Color.White : 'rgba(255,255,255,0.4)')
          }
          .onClick(() => {
            if (this.currentVideoIndex < this.videoList.length - 1) {
              this.playNext()
            }
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 16, bottom: 40 })
        .linearGradient({
          angle: 0,
          colors: [['rgba(0,0,0,0.7)', 0], ['rgba(0,0,0,0)', 1]]
        })
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: '-100%' })
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
