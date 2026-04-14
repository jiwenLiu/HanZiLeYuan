import router from '@ohos.router'
import { window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { media } from '@kit.MediaKit'
import { preferences } from '@kit.ArkData'
import { soundEffectService } from '../services/SoundEffectService'

// 题目类型
type QuizType = 'select' | 'listen' | 'combine' | 'picture'

interface QuizQuestion {
  id: number
  character: string
  options: string[]
  correctAnswer: string
  emoji: string
  audioFile: string
}

interface CombineQuestion {
  id: number
  part1: string
  part2: string
  options: string[]
  correctAnswer: string
  hint: string
}

interface PictureQuestion {
  id: number
  emoji: string
  description: string
  options: string[]
  correctAnswer: string
  audioFile: string
}

@Entry
@Component
struct QuizPage {
  // 页面状态
  @State currentMode: string = 'menu' // 'menu' | 'quiz'
  @State selectedQuizType: QuizType = 'select'

  // 游戏状态
  @State questions: QuizQuestion[] = []
  @State combineQuestions: CombineQuestion[] = []
  @State pictureQuestions: PictureQuestion[] = []
  @State currentQuestionIndex: number = 0
  @State selectedAnswer: number = -1
  @State score: number = 0
  @State showResult: boolean = false
  @State showFeedback: boolean = false
  @State isCorrectAnswer: boolean = false
  @State comboCount: number = 0
  @State maxCombo: number = 0
  @State totalTime: number = 0
  @State isAudioPlaying: boolean = false
  
  // 动画状态
  @State logoTranslateY: number = 0
  @State menuCardOffsets: number[] = [0, 0, 0, 0]

  private totalQuestions: number = 10
  private audioPlayer: media.AudioPlayer | null = null
  private timerInterval: number = -1
  private dataPreferences: preferences.Preferences | null = null
  private logoTimer: number = -1
  private menuAnimTimer: number = -1

  async aboutToAppear() {
    await this.setFullScreen()
    await this.initDataPreferences()
    await this.initAudioPlayer()
    
    // 启动logo浮动动画 - 更流畅的动画
    this.logoTimer = setInterval(() => {
      const time = Date.now() / 1000
      this.logoTranslateY = Math.sin(time * 1.5) * 12
    }, 16)  // 约60fps

    // 启动菜单卡片浮动动画 - 更流畅的动画
    this.menuAnimTimer = setInterval(() => {
      const time = Date.now() / 1000
      for (let i = 0; i < 4; i++) {
        this.menuCardOffsets[i] = Math.sin(time * 1.2 + i * 0.8) * 10
      }
    }, 16)  // 约60fps
  }

  aboutToDisappear() {
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval)
    }
    if (this.logoTimer !== -1) {
      clearInterval(this.logoTimer)
    }
    if (this.menuAnimTimer !== -1) {
      clearInterval(this.menuAnimTimer)
    }
    this.releaseAudioPlayer()
  }

  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      await mainWindow.setWindowLayoutFullScreen(true)
      await mainWindow.setWindowSystemBarEnable([])
      console.info('✅ QuizPage 全屏模式已启用')
    } catch (err) {
      console.error('❌ QuizPage 设置全屏失败:', JSON.stringify(err))
    }
  }

  async initDataPreferences() {
    try {
      const context = getContext(this) as common.UIAbilityContext
      this.dataPreferences = await preferences.getPreferences(context, 'quiz_data')
      console.info('✅ 问答数据存储初始化成功')
    } catch (err) {
      console.error('❌ 问答数据存储初始化失败:', JSON.stringify(err))
    }
  }

  // 初始化音频播放器
  async initAudioPlayer() {
    try {
      this.audioPlayer = await media.createAudioPlayer()
      this.audioPlayer.on('finish', () => {
        this.isAudioPlaying = false
        console.info('🔊 音频播放完成')
      })
      this.audioPlayer.on('error', (err) => {
        this.isAudioPlaying = false
        console.error('❌ 音频播放错误:', JSON.stringify(err))
      })
      console.info('✅ 音频播放器初始化成功')
    } catch (err) {
      console.error('❌ 音频播放器初始化失败:', JSON.stringify(err))
    }
  }

  // 释放音频播放器
  releaseAudioPlayer() {
    if (this.audioPlayer) {
      this.audioPlayer.release()
      this.audioPlayer = null
    }
  }

  // 播放汉字音频
  async playCharacterAudio(character: string) {
    if (!this.audioPlayer || this.isAudioPlaying) return

    try {
      const context = getContext(this) as common.UIAbilityContext
      const resourceManager = context.resourceManager
      const audioFileName = `audios/${character}.mp3`

      // 获取rawfile资源
      const rawFileDescriptor = await resourceManager.getRawFd(audioFileName)
      
      this.audioPlayer.reset()
      this.audioPlayer.fdSrc = rawFileDescriptor
      this.isAudioPlaying = true
      this.audioPlayer.play()
      console.info(`🔊 播放音频: ${audioFileName}`)
    } catch (err) {
      this.isAudioPlaying = false
      console.error(`❌ 播放音频失败 (${character}):`, JSON.stringify(err))
    }
  }

  // 初始化看字选字题目
  initSelectQuestions() {
    const allQuestions: QuizQuestion[] = [
      // 动物篇
      { id: 1, character: '马', options: ['马', '牛', '羊', '驴'], correctAnswer: '马', emoji: '🐴', audioFile: '马.mp3' },
      { id: 2, character: '牛', options: ['马', '牛', '羊', '猪'], correctAnswer: '牛', emoji: '🐂', audioFile: '牛.mp3' },
      { id: 3, character: '羊', options: ['牛', '马', '羊', '鹿'], correctAnswer: '羊', emoji: '🐑', audioFile: '羊.mp3' },
      { id: 4, character: '鸡', options: ['鸡', '鸭', '鹅', '鸟'], correctAnswer: '鸡', emoji: '🐔', audioFile: '鸡.mp3' },
      { id: 5, character: '狗', options: ['猫', '狗', '猪', '狼'], correctAnswer: '狗', emoji: '🐕', audioFile: '狗.mp3' },
      { id: 6, character: '猫', options: ['狗', '猪', '猫', '虎'], correctAnswer: '猫', emoji: '🐱', audioFile: '猫.mp3' },
      { id: 7, character: '猪', options: ['狗', '猪', '猫', '牛'], correctAnswer: '猪', emoji: '🐷', audioFile: '猪.mp3' },

      // 植物篇
      { id: 10, character: '木', options: ['林', '森', '木', '本'], correctAnswer: '木', emoji: '🌳', audioFile: '木.mp3' },
      { id: 11, character: '林', options: ['木', '林', '森', '树'], correctAnswer: '林', emoji: '🌲', audioFile: '林.mp3' },
      { id: 12, character: '森', options: ['木', '林', '森', '树'], correctAnswer: '森', emoji: '🌲', audioFile: '森.mp3' },
      { id: 13, character: '树', options: ['木', '林', '树', '森'], correctAnswer: '树', emoji: '🌳', audioFile: '树.mp3' },
      { id: 14, character: '桃', options: ['桃', '桑', '松', '柳'], correctAnswer: '桃', emoji: '🍑', audioFile: '桃.mp3' },
      { id: 15, character: '松', options: ['桃', '桑', '松', '柳'], correctAnswer: '松', emoji: '🌲', audioFile: '松.mp3' },

      // 自然篇
      { id: 19, character: '水', options: ['水', '泉', '川', '河'], correctAnswer: '水', emoji: '💧', audioFile: '水.mp3' },
      { id: 20, character: '泉', options: ['水', '泉', '川', '江'], correctAnswer: '泉', emoji: '⛲', audioFile: '泉.mp3' },
      { id: 21, character: '川', options: ['山', '水', '川', '河'], correctAnswer: '川', emoji: '🏞️', audioFile: '川.mp3' },
      { id: 22, character: '河', options: ['河', '江', '湖', '海'], correctAnswer: '河', emoji: '🌊', audioFile: '河.mp3' },
      { id: 23, character: '江', options: ['河', '江', '湖', '海'], correctAnswer: '江', emoji: '🌊', audioFile: '江.mp3' },
      { id: 24, character: '海', options: ['河', '江', '湖', '海'], correctAnswer: '海', emoji: '🌊', audioFile: '海.mp3' },

      // 身体篇
      { id: 28, character: '人', options: ['人', '从', '众', '个'], correctAnswer: '人', emoji: '👨', audioFile: '人.mp3' },
      { id: 29, character: '从', options: ['人', '从', '众', '双'], correctAnswer: '从', emoji: '👥', audioFile: '从.mp3' },
      { id: 30, character: '众', options: ['人', '从', '众', '多'], correctAnswer: '众', emoji: '👨‍👩‍👧‍👦', audioFile: '众.mp3' },
      { id: 31, character: '大', options: ['大', '太', '天', '夫'], correctAnswer: '大', emoji: '🔵', audioFile: '大.mp3' },
      { id: 32, character: '立', options: ['站', '立', '坐', '走'], correctAnswer: '立', emoji: '🧍', audioFile: '立.mp3' },

      // 日常篇
      { id: 37, character: '家', options: ['房', '家', '室', '宫'], correctAnswer: '家', emoji: '🏠', audioFile: '家.mp3' },
      { id: 38, character: '房', options: ['房', '家', '室', '屋'], correctAnswer: '房', emoji: '🏠', audioFile: '房.mp3' },
      { id: 39, character: '车', options: ['车', '辇', '舟', '船'], correctAnswer: '车', emoji: '🚗', audioFile: '车.mp3' },
      { id: 40, character: '船', options: ['车', '辇', '舟', '船'], correctAnswer: '船', emoji: '🚢', audioFile: '船.mp3' }
    ]

    // 随机选择题目并打乱选项顺序
    const selectedQuestions = allQuestions.sort(() => Math.random() - 0.5).slice(0, this.totalQuestions)
    this.questions = selectedQuestions.map((q: QuizQuestion) => {
      const shuffledOptions = q.options.slice().sort(() => Math.random() - 0.5)
      const result: QuizQuestion = {
        id: q.id,
        character: q.character,
        options: shuffledOptions,
        correctAnswer: q.correctAnswer,
        emoji: q.emoji,
        audioFile: q.audioFile
      }
      return result
    })
  }

  // 初始化组合识字题目
  initCombineQuestions() {
    const allQuestions: CombineQuestion[] = [
      { id: 1, part1: '木', part2: '木', options: ['森', '林', '树', '本'], correctAnswer: '林', hint: '两棵树' },
      { id: 2, part1: '林', part2: '木', options: ['森', '林', '树', '本'], correctAnswer: '森', hint: '很多树' },
      { id: 3, part1: '人', part2: '人', options: ['众', '从', '双', '俩'], correctAnswer: '从', hint: '跟随' },
      { id: 4, part1: '从', part2: '人', options: ['众', '从', '多', '群'], correctAnswer: '众', hint: '很多人' },
      { id: 5, part1: '日', part2: '月', options: ['明', '晶', '星', '光'], correctAnswer: '明', hint: '光亮' },
      { id: 6, part1: '日', part2: '日', options: ['晶', '明', '星', '昌'], correctAnswer: '昌', hint: '兴旺' },
      { id: 7, part1: '火', part2: '火', options: ['炎', '焱', '燃', '灯'], correctAnswer: '炎', hint: '很热' },
      { id: 8, part1: '口', part2: '口', options: ['吕', '品', '回', '囗'], correctAnswer: '吕', hint: '姓氏' },
      { id: 9, part1: '女', part2: '子', options: ['好', '妈', '姐', '妹'], correctAnswer: '好', hint: '美好' },
      { id: 10, part1: '山', part2: '山', options: ['出', '峦', '岳', '屾'], correctAnswer: '出', hint: '出去' }
    ]

    // 随机选择题目并打乱选项顺序
    const selectedQuestions = allQuestions.sort(() => Math.random() - 0.5).slice(0, this.totalQuestions)
    this.combineQuestions = selectedQuestions.map((q: CombineQuestion) => {
      const shuffledOptions = q.options.slice().sort(() => Math.random() - 0.5)
      const result: CombineQuestion = {
        id: q.id,
        part1: q.part1,
        part2: q.part2,
        options: shuffledOptions,
        correctAnswer: q.correctAnswer,
        hint: q.hint
      }
      return result
    })
  }

  // 初始化看图选字题目
  initPictureQuestions() {
    const allQuestions: PictureQuestion[] = [
      { id: 1, emoji: '🐴', description: '这是什么动物？', options: ['马', '牛', '羊', '驴'], correctAnswer: '马', audioFile: '马.mp3' },
      { id: 2, emoji: '🐂', description: '这是什么动物？', options: ['马', '牛', '羊', '猪'], correctAnswer: '牛', audioFile: '牛.mp3' },
      { id: 3, emoji: '🐑', description: '这是什么动物？', options: ['牛', '马', '羊', '鹿'], correctAnswer: '羊', audioFile: '羊.mp3' },
      { id: 4, emoji: '🐕', description: '这是什么动物？', options: ['猫', '狗', '猪', '狼'], correctAnswer: '狗', audioFile: '狗.mp3' },
      { id: 5, emoji: '🐱', description: '这是什么动物？', options: ['狗', '猪', '猫', '虎'], correctAnswer: '猫', audioFile: '猫.mp3' },
      { id: 6, emoji: '🌳', description: '这是什么植物？', options: ['林', '森', '木', '树'], correctAnswer: '树', audioFile: '树.mp3' },
      { id: 7, emoji: '💧', description: '这是什么？', options: ['水', '泉', '川', '河'], correctAnswer: '水', audioFile: '水.mp3' },
      { id: 8, emoji: '🌊', description: '这代表什么？', options: ['河', '江', '湖', '海'], correctAnswer: '海', audioFile: '海.mp3' },
      { id: 9, emoji: '🏠', description: '这是什么？', options: ['房', '家', '室', '宫'], correctAnswer: '家', audioFile: '家.mp3' },
      { id: 10, emoji: '🚗', description: '这是什么交通工具？', options: ['车', '辇', '舟', '船'], correctAnswer: '车', audioFile: '车.mp3' },
      { id: 11, emoji: '🚢', description: '这是什么交通工具？', options: ['车', '辇', '舟', '船'], correctAnswer: '船', audioFile: '船.mp3' },
      { id: 12, emoji: '☀️', description: '天上的太阳是？', options: ['日', '月', '星', '云'], correctAnswer: '日', audioFile: '日.mp3' },
      { id: 13, emoji: '🌙', description: '天上的月亮是？', options: ['日', '月', '星', '云'], correctAnswer: '月', audioFile: '月.mp3' },
      { id: 14, emoji: '🔥', description: '这是什么？', options: ['火', '水', '土', '风'], correctAnswer: '火', audioFile: '火.mp3' },
      { id: 15, emoji: '⛰️', description: '这是什么？', options: ['山', '水', '土', '石'], correctAnswer: '山', audioFile: '山.mp3' }
    ]

    this.pictureQuestions = allQuestions.sort(() => Math.random() - 0.5).slice(0, this.totalQuestions)
  }

  // 开始游戏
  startGame(quizType: QuizType) {
    this.selectedQuizType = quizType
    this.currentMode = 'quiz'
    this.currentQuestionIndex = 0
    this.selectedAnswer = -1
    this.score = 0
    this.showResult = false
    this.showFeedback = false
    this.isCorrectAnswer = false
    this.comboCount = 0
    this.maxCombo = 0
    this.totalTime = 0

    // 根据题型初始化题目
    if (quizType === 'select' || quizType === 'listen') {
      this.initSelectQuestions()
    } else if (quizType === 'combine') {
      this.initCombineQuestions()
    } else if (quizType === 'picture') {
      this.initPictureQuestions()
    }

    // 启动计时器
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval)
    }
    this.timerInterval = setInterval(() => {
      this.totalTime++
    }, 1000)

    // 听音选字模式自动播放第一题音频
    if (quizType === 'listen' && this.questions.length > 0) {
      setTimeout(() => {
        this.playCharacterAudio(this.questions[0].character)
      }, 500)
    }
  }

  // 检查答案
  checkAnswer(selectedOption: string, optionIndex: number) {
    if (this.selectedAnswer !== -1 || this.showFeedback) return

    this.selectedAnswer = optionIndex
    let correctAnswer = ''

    if (this.selectedQuizType === 'combine') {
      correctAnswer = this.combineQuestions[this.currentQuestionIndex].correctAnswer
    } else if (this.selectedQuizType === 'picture') {
      correctAnswer = this.pictureQuestions[this.currentQuestionIndex].correctAnswer
    } else {
      correctAnswer = this.questions[this.currentQuestionIndex].correctAnswer
    }

    this.isCorrectAnswer = selectedOption === correctAnswer

    if (this.isCorrectAnswer) {
      this.score++
      this.comboCount++
      if (this.comboCount > this.maxCombo) {
        this.maxCombo = this.comboCount
      }
      // 正确时播放正确答案的音频
      this.playCharacterAudio(correctAnswer)
    } else {
      this.comboCount = 0
    }

    this.showFeedback = true

    setTimeout(() => {
      this.showFeedback = false
      this.selectedAnswer = -1

      if (this.currentQuestionIndex < this.totalQuestions - 1) {
        this.currentQuestionIndex++
        // 听音选字模式自动播放下一题音频
        if (this.selectedQuizType === 'listen') {
          setTimeout(() => {
            this.playCharacterAudio(this.questions[this.currentQuestionIndex].character)
          }, 300)
        }
      } else {
        if (this.timerInterval !== -1) {
          clearInterval(this.timerInterval)
          this.timerInterval = -1
        }
        this.showResult = true
      }
    }, 1500)
  }

  // 格式化时间
  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
  }

  // 获取评价
  getEvaluation(): string {
    if (this.score === this.totalQuestions) return '🏆 完美满分！'
    if (this.score >= 8) return '🌟 太棒了！'
    if (this.score >= 6) return '👍 很不错！'
    if (this.score >= 4) return '💪 继续加油！'
    return '😊 多练习！'
  }

  // 返回菜单
  backToMenu() {
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval)
      this.timerInterval = -1
    }
    this.currentMode = 'menu'
  }

  // 获取当前题目的汉字（用于显示和播放音频）
  getCurrentCharacter(): string {
    if (this.selectedQuizType === 'combine') {
      return this.combineQuestions[this.currentQuestionIndex]?.correctAnswer || ''
    } else if (this.selectedQuizType === 'picture') {
      return this.pictureQuestions[this.currentQuestionIndex]?.correctAnswer || ''
    } else {
      return this.questions[this.currentQuestionIndex]?.character || ''
    }
  }

  // 获取当前题目的选项
  getCurrentOptions(): string[] {
    if (this.selectedQuizType === 'combine') {
      return this.combineQuestions[this.currentQuestionIndex]?.options || []
    } else if (this.selectedQuizType === 'picture') {
      return this.pictureQuestions[this.currentQuestionIndex]?.options || []
    } else {
      return this.questions[this.currentQuestionIndex]?.options || []
    }
  }

  // 获取当前题目的正确答案
  getCurrentCorrectAnswer(): string {
    if (this.selectedQuizType === 'combine') {
      return this.combineQuestions[this.currentQuestionIndex]?.correctAnswer || ''
    } else if (this.selectedQuizType === 'picture') {
      return this.pictureQuestions[this.currentQuestionIndex]?.correctAnswer || ''
    } else {
      return this.questions[this.currentQuestionIndex]?.correctAnswer || ''
    }
  }

  // 检查选项是否被选中
  isOptionSelected(index: number): boolean {
    return this.selectedAnswer === index
  }

  // 获取选项背景色
  getOptionBackgroundColor(index: number): string {
    if (this.selectedAnswer === index) {
      return this.isCorrectAnswer ? '#10b981' : '#ef4444'
    }
    return '#ffffff'
  }

  // 获取选项阴影颜色
  getOptionShadowColor(index: number): string {
    if (this.selectedAnswer === index) {
      return this.isCorrectAnswer ? 'rgba(16,185,129,0.4)' : 'rgba(239,68,68,0.4)'
    }
    return 'rgba(0,0,0,0.15)'
  }

  // 获取选项边框颜色
  getOptionBorderColor(index: number): string {
    if (this.selectedAnswer === index) {
      return this.isCorrectAnswer ? '#059669' : '#dc2626'
    }
    return '#e5e7eb'
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [['#f59e0b', 0], ['#f97316', 0.5], ['#ea580c', 1]]
        })

      if (this.currentMode === 'menu') {
        // 题型选择菜单
        this.MenuView()
      } else if (!this.showResult) {
        // 游戏界面
        this.GameView()
        // 反馈弹窗
        if (this.showFeedback) {
          this.FeedbackView()
        }
      } else {
        // 结果界面
        this.ResultView()
      }
    }
    .width('100%')
    .height('100%')
  }

  // 题型选择菜单
  @Builder
  MenuView() {
    Column() {
      // 顶部返回按钮
      Row() {
        Stack() {
          Column()
            .width(56)
            .height(56)
            .borderRadius(28)
            .linearGradient({
              angle: 135,
              colors: [['#fbbf24', 0], ['#f97316', 1]]
            })
            .shadow({ radius: 15, color: 'rgba(0,0,0,0.3)', offsetY: 4 })

          Text('←')
            .fontSize(28)
            .fontColor(Color.White)
        }
        .onClick(() => {
          router.back()
        })

        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 8 })

      // 标题区域（带浮动动画的图标）
      Column({ space: 4 }) {
        // 趣味相关的图标（带浮动动画）- 改为怪味豆图标
        Stack() {
          Column()
            .width(75)
            .height(75)
            .borderRadius(37.5)
            .linearGradient({
              angle: 135,
              colors: [['#fbbf24', 0], ['#ea580c', 1]]
            })
            .shadow({
              radius: 18,
              color: 'rgba(0, 0, 0, 0.3)',
              offsetX: 0,
              offsetY: 5
            })
          
          Text('🫘')
            .fontSize(38)
        }
        .translate({ y: this.logoTranslateY })

        Text('趣味问答')
          .fontSize(24)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 0 })

        Text('选择题目类型开始学习')
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.85)')
          .textAlign(TextAlign.Center)
          .lineHeight(16)
          .width('85%')
          .margin({ top: 0 })
      }
      .width('100%')
      .padding({ top: 5 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Blank().height(15)

      // 题型选择卡片（横向排列，带浮动动画）
      Row({ space: 10 }) {
        // 看字选字
        this.QuizTypeCard('📖', '看字选字', '看汉字选正确答案', 'select', '#3b82f6', 0)

        // 听音选字
        this.QuizTypeCard('🔊', '听音选字', '听发音选正确汉字', 'listen', '#10b981', 1)

        // 组合识字
        this.QuizTypeCard('🧩', '组合识字', '两个字组成新字', 'combine', '#8b5cf6', 2)

        // 看图选字
        this.QuizTypeCard('🖼️', '看图选字', '看图片选正确汉字', 'picture', '#ec4899', 3)
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.Center)

      Blank().layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  // 题型卡片
  @Builder
  QuizTypeCard(emoji: string, title: string, desc: string, type: QuizType, color: string, cardIndex: number) {
    Column({ space: 6 }) {
      Text(emoji)
        .fontSize(36)

      Text(title)
        .fontSize(15)
        .fontColor('#1e3a8a')
        .fontWeight(FontWeight.Bold)

      Text(desc)
        .fontSize(10)
        .fontColor('#64748b')
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(135)
    .height(135)
    .padding(10)
    .linearGradient({
      angle: 135,
      colors: [['#fef3c7', 0], ['#fde68a', 1]]
    })
    .borderRadius(18)
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.15)', offsetY: 3 })
    .border({ width: 2, color: color })
    .translate({ y: this.menuCardOffsets[cardIndex] })
    .onClick(() => {
      this.startGame(type)
    })
  }

  // 游戏界面
  @Builder
  GameView() {
    Row() {
      // 左侧控制区
      Column({ space: 16 }) {
        // 返回按钮
        Stack() {
          Column()
            .width(50)
            .height(50)
            .borderRadius(25)
            .linearGradient({
              angle: 135,
              colors: [['#fbbf24', 0], ['#f97316', 1]]
            })
            .shadow({ radius: 12, color: 'rgba(0,0,0,0.3)', offsetY: 3 })

          Text('←')
            .fontSize(24)
            .fontColor(Color.White)
        }
        .onClick(() => {
          this.backToMenu()
        })

        // 题型标识
        Column({ space: 4 }) {
          Text(this.selectedQuizType === 'select' ? '📖' :
            this.selectedQuizType === 'listen' ? '🔊' :
              this.selectedQuizType === 'combine' ? '🧩' : '🖼️')
            .fontSize(32)

          Text(this.selectedQuizType === 'select' ? '看字选字' :
            this.selectedQuizType === 'listen' ? '听音选字' :
              this.selectedQuizType === 'combine' ? '组合识字' : '看图选字')
            .fontSize(14)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

        // 得分显示
        Column({ space: 4 }) {
          Text('得分')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.8)')

          Text(`${this.score}`)
            .fontSize(32)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .padding(12)
        .backgroundColor('rgba(0,0,0,0.2)')
        .borderRadius(16)

        // 连击显示
        if (this.comboCount >= 2) {
          Column() {
            Text(`🔥 ${this.comboCount}连击`)
              .fontSize(14)
              .fontColor('#fbbf24')
              .fontWeight(FontWeight.Bold)
          }
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor('rgba(0,0,0,0.3)')
          .borderRadius(10)
        }

        // 计时器
        Text(`⏱️ ${this.formatTime(this.totalTime)}`)
          .fontSize(16)
          .fontColor(Color.White)

        Blank()

        // 进度
        Column({ space: 8 }) {
          Text(`${this.currentQuestionIndex + 1}/${this.totalQuestions}`)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.9)')

          Progress({ value: this.currentQuestionIndex + 1, total: this.totalQuestions, type: ProgressType.Linear })
            .width(90)
            .color('#fbbf24')
            .backgroundColor('rgba(255,255,255,0.3)')
            .height(6)
            .borderRadius(3)
        }
      }
      .width(140)
      .height('100%')
      .padding({ left: 16, top: 16, bottom: 16, right: 8 })
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)

      // 中间问题区
      Column({ space: 16 }) {
        if (this.selectedQuizType === 'select') {
          // 看字选字 - 显示汉字
          this.SelectQuestionView()
        } else if (this.selectedQuizType === 'listen') {
          // 听音选字 - 显示播放按钮
          this.ListenQuestionView()
        } else if (this.selectedQuizType === 'combine') {
          // 组合识字 - 显示两个字
          this.CombineQuestionView()
        } else {
          // 看图选字 - 显示图片
          this.PictureQuestionView()
        }
      }
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 右侧选项区
      Column({ space: 12 }) {
        ForEach(this.getCurrentOptions(), (option: string, index: number) => {
          this.OptionButton(option, index)
        }, (option: string, index: number) => `q${this.currentQuestionIndex}_opt${index}`)
      }
      .width(200)
      .height('100%')
      .padding({ right: 16, top: 16, bottom: 16 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  // 看字选字题目视图
  @Builder
  SelectQuestionView() {
    Column({ space: 20 }) {
      // 显示汉字
      Stack() {
        Column()
          .width(160)
          .height(160)
          .borderRadius(24)
          .backgroundColor(Color.White)
          .shadow({ radius: 25, color: 'rgba(0,0,0,0.2)', offsetY: 6 })

        Text(this.questions[this.currentQuestionIndex]?.character || '')
          .fontSize(100)
          .fontColor('#1e3a8a')
          .fontWeight(FontWeight.Bold)
      }

      // 播放音频按钮
      Row({ space: 8 }) {
        Text(this.isAudioPlaying ? '🔊' : '🔈')
          .fontSize(24)

        Text('听发音')
          .fontSize(16)
          .fontColor(Color.White)
      }
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor('rgba(0,0,0,0.3)')
      .borderRadius(20)
      .onClick(() => {
        this.playCharacterAudio(this.questions[this.currentQuestionIndex]?.character || '')
      })

      Text('请选择正确的汉字')
        .fontSize(18)
        .fontColor('rgba(255,255,255,0.9)')
    }
  }

  // 听音选字题目视图
  @Builder
  ListenQuestionView() {
    Column({ space: 20 }) {
      // 大播放按钮
      Stack() {
        Column()
          .width(160)
          .height(160)
          .borderRadius(80)
          .backgroundColor(Color.White)
          .shadow({ radius: 25, color: 'rgba(0,0,0,0.2)', offsetY: 6 })

        Text(this.isAudioPlaying ? '🔊' : '▶')
          .fontSize(80)
          .fontColor(this.isAudioPlaying ? '#10b981' : '#3b82f6')
      }
      .onClick(() => {
        this.playCharacterAudio(this.questions[this.currentQuestionIndex]?.character || '')
      })

      Text(this.isAudioPlaying ? '正在播放...' : '点击播放发音')
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)

      Text('听发音，选出正确的汉字')
        .fontSize(16)
        .fontColor('rgba(255,255,255,0.8)')
    }
  }

  // 组合识字题目视图
  @Builder
  CombineQuestionView() {
    Column({ space: 16 }) {
      // 两个字的组合
      Row({ space: 16 }) {
        // 第一个字
        Stack() {
          Column()
            .width(100)
            .height(100)
            .borderRadius(20)
            .backgroundColor(Color.White)
            .shadow({ radius: 15, color: 'rgba(0,0,0,0.15)', offsetY: 4 })

          Text(this.combineQuestions[this.currentQuestionIndex]?.part1 || '')
            .fontSize(60)
            .fontColor('#1e3a8a')
            .fontWeight(FontWeight.Bold)
        }
        .onClick(() => {
          this.playCharacterAudio(this.combineQuestions[this.currentQuestionIndex]?.part1 || '')
        })

        Text('+')
          .fontSize(40)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)

        // 第二个字
        Stack() {
          Column()
            .width(100)
            .height(100)
            .borderRadius(20)
            .backgroundColor(Color.White)
            .shadow({ radius: 15, color: 'rgba(0,0,0,0.15)', offsetY: 4 })

          Text(this.combineQuestions[this.currentQuestionIndex]?.part2 || '')
            .fontSize(60)
            .fontColor('#1e3a8a')
            .fontWeight(FontWeight.Bold)
        }
        .onClick(() => {
          this.playCharacterAudio(this.combineQuestions[this.currentQuestionIndex]?.part2 || '')
        })

        Text('=')
          .fontSize(40)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)

        Text('❓')
          .fontSize(60)
      }

      // 提示
      Text(`提示：${this.combineQuestions[this.currentQuestionIndex]?.hint || ''}`)
        .fontSize(16)
        .fontColor('rgba(255,255,255,0.9)')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('rgba(0,0,0,0.2)')
        .borderRadius(12)
    }
  }

  // 看图选字题目视图
  @Builder
  PictureQuestionView() {
    Column({ space: 20 }) {
      // 显示emoji图片
      Stack() {
        Column()
          .width(160)
          .height(160)
          .borderRadius(24)
          .backgroundColor(Color.White)
          .shadow({ radius: 25, color: 'rgba(0,0,0,0.2)', offsetY: 6 })

        Text(this.pictureQuestions[this.currentQuestionIndex]?.emoji || '')
          .fontSize(100)
      }

      // 问题描述
      Text(this.pictureQuestions[this.currentQuestionIndex]?.description || '')
        .fontSize(22)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .textShadow({ radius: 4, color: 'rgba(0,0,0,0.3)' })
    }
  }

  // 选项按钮
  @Builder
  OptionButton(option: string, index: number) {
    Stack() {
      Column()
        .width('100%')
        .height(68)
        .borderRadius(18)
        .backgroundColor(this.getOptionBackgroundColor(index))
        .shadow({
          radius: this.isOptionSelected(index) ? 20 : 12,
          color: this.getOptionShadowColor(index),
          offsetY: 3
        })
        .border({
          width: this.isOptionSelected(index) ? 3 : 2,
          color: this.getOptionBorderColor(index)
        })

      Row({ space: 10 }) {
        // 选项字母
        Text(['A', 'B', 'C', 'D'][index])
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isOptionSelected(index) ? Color.White : '#f59e0b')
          .width(28)
          .height(28)
          .textAlign(TextAlign.Center)
          .borderRadius(14)
          .backgroundColor(this.isOptionSelected(index) ? 'rgba(255,255,255,0.3)' : 'rgba(245,158,11,0.15)')

        // 选项汉字
        Text(option)
          .fontSize(36)
          .fontColor(this.isOptionSelected(index) ? Color.White : '#1e3a8a')
          .fontWeight(FontWeight.Bold)
      }
    }
    .width(180)
    .height(68)
    .onClick(() => {
      if (this.selectedAnswer === -1 && !this.showFeedback) {
        this.checkAnswer(option, index)
      }
    })
  }

  // 反馈弹窗
  @Builder
  FeedbackView() {
    Column() {
      Column({ space: 16 }) {
        Text(this.isCorrectAnswer ? '🎉' : '😢')
          .fontSize(80)

        Text(this.isCorrectAnswer ? '回答正确！' : '回答错误')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isCorrectAnswer ? '#10b981' : '#ef4444')

        if (!this.isCorrectAnswer) {
          Text(`正确答案：${this.getCurrentCorrectAnswer()}`)
            .fontSize(24)
            .fontColor('#10b981')
            .fontWeight(FontWeight.Bold)
        }

        if (this.isCorrectAnswer && this.comboCount >= 2) {
          Text(`🔥 ${this.comboCount}连击！`)
            .fontSize(20)
            .fontColor('#f59e0b')
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('65%')
      .padding(36)
      .backgroundColor(Color.White)
      .borderRadius(24)
      .shadow({ radius: 30, color: 'rgba(0,0,0,0.3)', offsetY: 6 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('rgba(0,0,0,0.5)')
  }

  // 结果界面
  @Builder
  ResultView() {
    Column() {
      Column({ space: 20 }) {
        // 评价
        Text(this.getEvaluation())
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textShadow({ radius: 6, color: 'rgba(0,0,0,0.3)' })

        // 得分
        Row({ space: 8 }) {
          Text('得分：')
            .fontSize(24)
            .fontColor('rgba(255,255,255,0.9)')

          Text(`${this.score}/${this.totalQuestions}`)
            .fontSize(32)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }

        // 星级
        Row({ space: 4 }) {
          ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], (num: number) => {
            Text(num <= this.score ? '⭐' : '☆')
              .fontSize(24)
          }, (num: number) => `star${num}`)
        }

        // 统计
        Row({ space: 20 }) {
          Column({ space: 4 }) {
            Text('⏱️')
              .fontSize(24)
            Text(this.formatTime(this.totalTime))
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
            Text('用时')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .padding(12)
          .backgroundColor('rgba(0,0,0,0.2)')
          .borderRadius(12)

          Column({ space: 4 }) {
            Text('🔥')
              .fontSize(24)
            Text(`${this.maxCombo}`)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
            Text('最大连击')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .padding(12)
          .backgroundColor('rgba(0,0,0,0.2)')
          .borderRadius(12)

          Column({ space: 4 }) {
            Text('📊')
              .fontSize(24)
            Text(`${Math.round((this.score / this.totalQuestions) * 100)}%`)
              .fontSize(18)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
            Text('正确率')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.7)')
          }
          .padding(12)
          .backgroundColor('rgba(0,0,0,0.2)')
          .borderRadius(12)
        }

        // 按钮
        Row({ space: 16 }) {
          Button('再来一次')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor('#10b981')
            .borderRadius(24)
            .width(140)
            .height(52)
            .shadow({ radius: 15, color: 'rgba(16,185,129,0.4)', offsetY: 4 })
            .onClick(() => {
              this.startGame(this.selectedQuizType)
            })

          Button('换个题型')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e3a8a')
            .backgroundColor(Color.White)
            .borderRadius(24)
            .width(140)
            .height(52)
            .shadow({ radius: 15, color: 'rgba(0,0,0,0.2)', offsetY: 4 })
            .onClick(() => {
              this.backToMenu()
            })

          Button('返回首页')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#64748b')
            .backgroundColor('rgba(255,255,255,0.8)')
            .borderRadius(24)
            .width(140)
            .height(52)
            .onClick(() => {
              router.back()
            })
        }
        .margin({ top: 12 })
      }
      .width('85%')
      .padding(36)
      .backgroundColor('rgba(255,255,255,0.2)')
      .borderRadius(28)
      .shadow({ radius: 30, color: 'rgba(0,0,0,0.25)', offsetY: 6 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}


