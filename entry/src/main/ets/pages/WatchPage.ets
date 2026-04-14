import router from '@ohos.router'
import { window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { soundEffectService } from '../services/SoundEffectService'

interface VideoInfo {
  id: string
  title: string
  subtitle: string
  emoji: string
  duration: string
  status: string
  category: string
}

@Entry
@Component
struct WatchPage {
  @State currentPage: number = 0
  @State backButtonScale: number = 1
  @State cardAnimations: number[] = []
  private animationTimer: number = -1
  
  // 47个视频课程（完整版）
  @State allVideos: VideoInfo[] = [
    { id: '1', title: '第1课', subtitle: '《马牛羊鸡犬豕》', emoji: '🐴', duration: '12:45', status: 'not_started', category: 'animals' },
    { id: '2', title: '第2课', subtitle: '《鸟鹊鸠鸽鸦鹤》', emoji: '🐦', duration: '14:10', status: 'not_started', category: 'animals' },
    { id: '3', title: '第3课', subtitle: '《燕雁鹰鹳》', emoji: '🦅', duration: '12:15', status: 'not_started', category: 'animals' },
    { id: '4', title: '第4课', subtitle: '《鱼龟虾蟹》', emoji: '🐟', duration: '14:25', status: 'not_started', category: 'animals' },
    { id: '5', title: '第5课', subtitle: '《木林森本末朱》', emoji: '🌳', duration: '12:00', status: 'not_started', category: 'plants' },
    { id: '6', title: '第6课', subtitle: '《米禾秧稻谷麦》', emoji: '🌾', duration: '11:15', status: 'not_started', category: 'plants' },
    { id: '7', title: '第7课', subtitle: '《瓜豆瓢瓣菜瓜》', emoji: '🥒', duration: '13:05', status: 'not_started', category: 'plants' },
    { id: '8', title: '第8课', subtitle: '《水泉川州洲》', emoji: '💧', duration: '14:35', status: 'not_started', category: 'nature' },
    { id: '9', title: '第9课', subtitle: '《江河湖海》', emoji: '🌊', duration: '8:20', status: 'not_started', category: 'nature' },
    { id: '10', title: '第10课', subtitle: '《厂石原源》', emoji: '🏭', duration: '13:00', status: 'not_started', category: 'nature' },
    { id: '11', title: '第11课', subtitle: '《山岩岭峰峡》', emoji: '⛰️', duration: '12:20', status: 'not_started', category: 'nature' },
    { id: '12', title: '第12课', subtitle: '《田土圭壤尘》', emoji: '🌱', duration: '14:15', status: 'not_started', category: 'nature' },
    { id: '13', title: '第13课', subtitle: '《日月星辰》', emoji: '☀️', duration: '9:15', status: 'not_started', category: 'astronomy' },
    { id: '14', title: '第14课', subtitle: '《旦早晚昏星》', emoji: '⏰', duration: '10:20', status: 'not_started', category: 'astronomy' },
    { id: '15', title: '第15课', subtitle: '《时光春夏》', emoji: '🌸', duration: '13:50', status: 'not_started', category: 'astronomy' },
    { id: '16', title: '第16课', subtitle: '《秋冬雪霜》', emoji: '❄️', duration: '12:25', status: 'not_started', category: 'astronomy' },
    { id: '17', title: '第17课', subtitle: '《风雨雷云冬》', emoji: '🌧️', duration: '12:45', status: 'not_started', category: 'astronomy' },
    { id: '18', title: '第18课', subtitle: '《火炎灾炭灰》', emoji: '🔥', duration: '16:20', status: 'not_started', category: 'color' },
    { id: '19', title: '第19课', subtitle: '《赤橙黄绿青蓝》', emoji: '🎨', duration: '14:05', status: 'not_started', category: 'color' },
    { id: '20', title: '第20课', subtitle: '《紫白黑灰棕褐》', emoji: '🎨', duration: '16:00', status: 'not_started', category: 'color' },
    { id: '21', title: '第21课', subtitle: '《红黄灰赤黑炭燃》', emoji: '🔥', duration: '15:00', status: 'not_started', category: 'color' },
    { id: '22', title: '第22课', subtitle: '《金银铜铁锡铅》', emoji: '⚙️', duration: '12:55', status: 'not_started', category: 'color' },
    { id: '23', title: '第23课', subtitle: '《人从众比北》', emoji: '👨', duration: '12:50', status: 'not_started', category: 'people' },
    { id: '24', title: '第24课', subtitle: '《大太立站交文美》', emoji: '👨‍👩‍👧‍👦', duration: '11:35', status: 'not_started', category: 'people' },
    { id: '25', title: '第25课', subtitle: '《保孙儿孩》', emoji: '👶', duration: '11:55', status: 'not_started', category: 'people' },
    { id: '26', title: '第26课', subtitle: '《女子母每妇姐妹》', emoji: '👩', duration: '16:15', status: 'not_started', category: 'people' },
    { id: '27', title: '第27课', subtitle: '《父男兄弟叔舅》', emoji: '👨', duration: '22:20', status: 'not_started', category: 'people' },
    { id: '28', title: '第28课', subtitle: '《爸妈爷奶姥爷姥姥》', emoji: '👴', duration: '11:50', status: 'not_started', category: 'people' },
    { id: '29', title: '第29课', subtitle: '《元元页页头首》', emoji: '👤', duration: '20:30', status: 'not_started', category: 'body' },
    { id: '30', title: '第30课', subtitle: '《目眉睛眼睁》', emoji: '👁️', duration: '13:00', status: 'not_started', category: 'body' },
    { id: '31', title: '第31课', subtitle: '《耳听聪聋》', emoji: '👂', duration: '9:55', status: 'not_started', category: 'body' },
    { id: '32', title: '第32课', subtitle: '《鼻自臭嗅闻》', emoji: '👃', duration: '13:20', status: 'not_started', category: 'body' },
    { id: '33', title: '第33课', subtitle: '《户门扇窗开关》', emoji: '🚪', duration: '14:10', status: 'not_started', category: 'daily' },
    { id: '34', title: '第34课', subtitle: '《口舌齿牙唇吃》', emoji: '👄', duration: '15:50', status: 'not_started', category: 'body' },
    { id: '35', title: '第35课', subtitle: '《自己身体》', emoji: '🧍', duration: '9:30', status: 'not_started', category: 'body' },
    { id: '36', title: '第36课', subtitle: '《手拿打扫挥拍》', emoji: '✋', duration: '12:00', status: 'not_started', category: 'body' },
    { id: '37', title: '第37课', subtitle: '《止步走趾跑路》', emoji: '🚶', duration: '10:35', status: 'not_started', category: 'body' },
    { id: '38', title: '第38课', subtitle: '《肉皮毛发》', emoji: '💪', duration: '14:15', status: 'not_started', category: 'body' },
    { id: '39', title: '第39课', subtitle: '《血吃饱肚饿肥》', emoji: '🍽️', duration: '14:35', status: 'not_started', category: 'body' },
    { id: '40', title: '第40课', subtitle: '《家宅室房屋》', emoji: '🏠', duration: '11:30', status: 'not_started', category: 'daily' },
    { id: '41', title: '第41课', subtitle: '《门窗桌椅床》', emoji: '🪑', duration: '14:25', status: 'not_started', category: 'daily' },
    { id: '42', title: '第42课', subtitle: '《刀匕剪刃》', emoji: '🔪', duration: '10:25', status: 'not_started', category: 'daily' },
    { id: '44', title: '第44课', subtitle: '《巾布冠带》', emoji: '👔', duration: '12:25', status: 'not_started', category: 'daily' },
    { id: '45', title: '第45课', subtitle: '《贝玉朋宝》', emoji: '💎', duration: '10:15', status: 'not_started', category: 'daily' },
    { id: '46', title: '第46课', subtitle: '《网罟洗涤》', emoji: '🧺', duration: '12:10', status: 'not_started', category: 'daily' },
    { id: '47', title: '第47课', subtitle: '《来去走进》', emoji: '🚶', duration: '12:45', status: 'not_started', category: 'daily' },
    { id: '48', title: '第48课', subtitle: '《车轮轴辐》', emoji: '🚗', duration: '14:15', status: 'not_started', category: 'daily' }
  ]

  async aboutToAppear() {
    await this.setFullScreen()
    // 初始化动画数组
    this.cardAnimations = new Array(this.allVideos.length).fill(0)
    // 启动动画
    this.startCardAnimations()
    this.startBackButtonAnimation()
  }

  // 设置全屏沉浸式模式
  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      
      await mainWindow.setWindowLayoutFullScreen(true)
      await mainWindow.setWindowSystemBarEnable([])
      
      console.info('✅ WatchPage 全屏模式已启用')
    } catch (err) {
      console.error('❌ WatchPage 设置全屏失败:', JSON.stringify(err))
    }
  }

  startBackButtonAnimation() {
    setInterval(() => {
      this.backButtonScale = this.backButtonScale === 1 ? 1.05 : 1
    }, 1500)
  }

  // 获取课程描述
  getCourseDescription(courseId: string): string {
    const descriptions: Record<string, string> = {
      '1': '学习马、牛、羊三个象形字',
      '2': '认识家养动物',
      '3': '天上飞、水里游、地上爬',
      '4': '鸟类飞翔的动作',
      '5': '从一棵树到森林',
      '6': '各种各样的树',
      '7': '农作物和果实',
      '8': '太阳、月亮、星星',
      '9': '水的不同形态',
      '10': '山和石头',
      '11': '天空和大地',
      '12': '风雷电霜',
      '13': '四季变化',
      '14': '方位词',
      '15': '位置关系',
      '16': '空间关系',
      '17': '颜色词',
      '18': '颜色词',
      '19': '颜色词',
      '20': '火和光',
      '21': '黑暗和夜晚',
      '22': '温度感觉',
      '23': '人的称呼',
      '24': '家庭成员',
      '25': '亲属关系',
      '26': '头部',
      '27': '面部',
      '28': '眼睛',
      '29': '耳朵',
      '30': '鼻子',
      '31': '嘴巴',
      '32': '手部',
      '33': '腿脚',
      '34': '身体',
      '35': '内脏',
      '36': '身体组织',
      '37': '体液',
      '38': '行走动作',
      '39': '姿势',
      '40': '感官动作',
      '41': '情绪表达',
      '42': '饮食动作',
      '43': '衣服相关',
      '44': '布料和装饰',
      '45': '珍宝相关',
      '46': '洗浴相关',
      '47': '来去相关',
      '48': '坐的姿势'
    }
    return descriptions[courseId] || '汉字学习'
  }

  // 获取当前页的视频（每页6个，2行x3列）
  getCurrentPageVideos(): VideoInfo[] {
    const startIndex = this.currentPage * 6
    return this.allVideos.slice(startIndex, startIndex + 6)
  }

  // 获取总页数
  getTotalPages(): number {
    return Math.ceil(this.allVideos.length / 6)
  }

  aboutToDisappear() {
    // 清理定时器
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer)
    }
  }

  startCardAnimations() {
    this.animationTimer = setInterval(() => {
      this.cardAnimations = this.cardAnimations.map((_, index) => {
        return Math.sin(Date.now() / 1000 + index * 0.5) * 8
      })
    }, 50)
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
          colors: [['#4a1d96', 0], ['#6b2fb5', 0.5], ['#8b4fd9', 1]]
        })

      // 主内容（不使用Scroll）
      Column() {
        // 顶部区域
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
          .scale({ x: this.backButtonScale, y: this.backButtonScale })
          .animation({
            duration: 1500,
            curve: Curve.EaseInOut
          })
          .onClick(() => {
            soundEffectService.playClickSound();
            router.back()
          })

          Blank()

          // 分页信息（居中）
          Text(`${this.currentPage + 1}/${this.getTotalPages()}`)
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .backgroundColor('rgba(255,255,255,0.3)')
            .backdropBlur(10)
            .borderRadius(20)
            .border({ width: 1, color: 'rgba(255,255,255,0.5)' })
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.3)' })

          Blank()

          // 右侧占位（保持对称）
          Column()
            .width(56)
            .height(56)
        }
        .width('100%')
        .padding({ left: 32, right: 32, top: 40 })  // top: 0 → 40
        .alignItems(VerticalAlign.Center)

        // 上边距（减少权重，内容上移）
        Column().layoutWeight(0.01)

        // 视频卡片区域
        Row({ space: 12 }) {
          // 左箭头（使用黄橙色图片资源，与返回按钮颜色一致）
          Image($r('app.media.ic_arrow_left'))
            .width(80)
            .height(80)
            .opacity(this.currentPage > 0 ? 1 : 0.3)
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

          // 视频网格（2行x3列）
          Column({ space: 10 }) {
            ForEach([0, 1], (rowIndex: number) => {
              Row({ space: 10 }) {
                ForEach(this.getCurrentPageVideos().slice(rowIndex * 3, rowIndex * 3 + 3), (video: VideoInfo) => {
                  // 视频卡片组件（添加浮动动画）
                  Column({ space: 6 }) {
                    // Emoji图标（进一步缩小以显示更多内容）
                    Text(video.emoji)
                      .fontSize(32)  // 38 → 32，再缩小16%
                      .textAlign(TextAlign.Center)
                      .margin({ top: 0, bottom: 2 })

                    // 课程标题（再缩小）
                    Text(`${video.title}${video.subtitle}`)
                      .fontSize(11)
                      .fontColor(Color.White)
                      .fontWeight(FontWeight.Bold)
                      .textAlign(TextAlign.Center)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    // 课程描述（再缩小）
                    Text(this.getCourseDescription(video.id))
                      .fontSize(8)
                      .fontColor('rgba(255,255,255,0.9)')
                      .textAlign(TextAlign.Center)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ bottom: 4 })

                    // 底部信息栏
                    Row({ space: 5 }) {
                      Text(`⏱️ ${video.duration}`)
                        .fontSize(8)
                        .fontColor(Color.White)
                        .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                        .backgroundColor('rgba(255,255,255,0.3)')
                        .borderRadius(6)

                      // 星级显示（每个组件都显示）
                      Row({ space: 2 }) {
                        Text(video.status === 'completed' ? '⭐' : '⭐').fontSize(11)
                        Text(video.status === 'completed' ? '⭐' : '⭐').fontSize(11)
                        Text(video.status === 'completed' ? '⭐' : '☆').fontSize(11)
                      }
                      
                      // 学习状态标签
                      Text(video.status === 'completed' ? '已完成' : video.status === 'in_progress' ? '学习中' : '未开始')
                        .fontSize(7)
                        .fontColor(Color.White)
                        .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                        .backgroundColor(video.status === 'completed' ? 'rgba(76,175,80,0.8)' : video.status === 'in_progress' ? 'rgba(255,193,7,0.8)' : 'rgba(158,158,158,0.8)')
                        .borderRadius(4)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Center)
                  }
                  .width('30%')
                  .aspectRatio(1.43)
                  .padding(20)
                  .borderRadius(24)
                  .linearGradient({
                    angle: 135,
                    colors: [['rgba(52,211,153,0.8)', 0], ['rgba(5,150,105,0.8)', 1]]
                  })
                  .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)' })
                  .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
                  .opacity(0.85)
                  .backdropBlur(10)
                  .translate({ 
                    y: this.cardAnimations[this.currentPage * 6 + rowIndex * 3 + (parseInt(video.id) - 1) % 3] || 0
                  })
                  .onClick(() => {
                    soundEffectService.playClickSound();
                    router.pushUrl({
                      url: 'pages/VideoPlayerPage',
                      params: { courseId: video.id, courseName: `${video.title}${video.subtitle}` }
                    })
                  })
                }, (video: VideoInfo) => video.id)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }, (rowIndex: number) => rowIndex.toString())
          }
          .layoutWeight(1)
          .gesture(
            PanGesture({ direction: PanDirection.Horizontal })
              .onActionEnd((event: GestureEvent) => {
                if (event.offsetX > 50) {
                  this.previousPage()
                } else if (event.offsetX < -50) {
                  this.nextPage()
                }
              })
          )

          // 右箭头（使用黄橙色图片资源，与返回按钮颜色一致）
          Image($r('app.media.ic_arrow_right'))
            .width(80)
            .height(80)
            .opacity(this.currentPage < this.getTotalPages() - 1 ? 1 : 0.3)
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
        .padding({ left: 32, right: 32 })

        // 页码指示器（48个视频÷6=8页）
        Row({ space: 8 }) {
          ForEach(Array.from<number, number>({ length: this.getTotalPages() }, (_, i: number): number => i), (pageIndex: number) => {
            Circle()
              .width(8)
              .height(8)
              .fill(this.currentPage === pageIndex ? Color.White : 'rgba(255,255,255,0.4)')
              .shadow({ radius: 10, color: 'rgba(0,0,0,0.3)' })
          }, (pageIndex: number) => pageIndex.toString())
        }
        .margin({ top: 0 })

        // 下边距（增加权重，内容上移）
        Column().layoutWeight(0.91)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}
































