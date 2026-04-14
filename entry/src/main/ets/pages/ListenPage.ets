import { router, window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { audioPlayService } from '../services/AudioPlayService'
import { soundEffectService } from '../services/SoundEffectService'
import preferences from '@ohos.data.preferences'

@Entry
@Component
struct ListenPage {
  @State currentIndex: number = 0
  @State isPlaying: boolean = false
  @State currentGroupIndex: number = 0  // 当前显示的组索引（0-3）
  @State displayAudioList: AudioInfo[] = []  // 当前显示的15个汉字
  @State showGroupSelector: boolean = false  // 显示分组选择器
  
  private dataPreferences: preferences.Preferences | null = null
  private readonly GROUP_SIZE: number = 15  // 每组15个
  private readonly TOTAL_GROUPS: number = 4  // 总共4组（48/15=3.2，向上取整为4组）
  
  // 48个汉字对应48个视频课程（完整列表）
  private allAudioList: AudioInfo[] = [
    // 动物篇 (1-4)
    { id: 1, char: '马', pinyin: 'mǎ', meaning: '善于奔跑的动物', emoji: '🐴', audioPath: 'audios/马.mp3' },
    { id: 2, char: '鸡', pinyin: 'jī', meaning: '会打鸣的家禽', emoji: '🐔', audioPath: 'audios/鸡.mp3' },
    { id: 3, char: '鸟', pinyin: 'niǎo', meaning: '会飞的动物', emoji: '🐦', audioPath: 'audios/鸟.mp3' },
    { id: 4, char: '羽', pinyin: 'yǔ', meaning: '鸟的羽毛', emoji: '🪶', audioPath: 'audios/羽.mp3' },
    
    // 植物篇 (5-7)
    { id: 5, char: '木', pinyin: 'mù', meaning: '树木的总称', emoji: '🪵', audioPath: 'audios/木.mp3' },
    { id: 6, char: '树', pinyin: 'shù', meaning: '高大的植物', emoji: '🌳', audioPath: 'audios/树.mp3' },
    { id: 7, char: '米', pinyin: 'mǐ', meaning: '粮食作物', emoji: '🍚', audioPath: 'audios/米.mp3' },
    
    // 自然篇 (8-22)
    { id: 8, char: '水', pinyin: 'shuǐ', meaning: '生命之源', emoji: '💧', audioPath: 'audios/水.mp3' },
    { id: 9, char: '河', pinyin: 'hé', meaning: '流动的水', emoji: '🌊', audioPath: 'audios/河.mp3' },
    { id: 10, char: '厂', pinyin: 'chǎng', meaning: '工厂', emoji: '🏭', audioPath: 'audios/厂.mp3' },
    { id: 11, char: '山', pinyin: 'shān', meaning: '高山', emoji: '⛰️', audioPath: 'audios/山.mp3' },
    { id: 12, char: '田', pinyin: 'tián', meaning: '农田', emoji: '🌾', audioPath: 'audios/田.mp3' },
    { id: 13, char: '土', pinyin: 'tǔ', meaning: '泥土', emoji: '🟫', audioPath: 'audios/土.mp3' },
    { id: 14, char: '日', pinyin: 'rì', meaning: '太阳', emoji: '☀️', audioPath: 'audios/日.mp3' },
    { id: 15, char: '时', pinyin: 'shí', meaning: '时间', emoji: '⏰', audioPath: 'audios/时.mp3' },
    { id: 16, char: '雨', pinyin: 'yǔ', meaning: '下雨', emoji: '🌧️', audioPath: 'audios/雨.mp3' },
    { id: 17, char: '春', pinyin: 'chūn', meaning: '春天', emoji: '🌸', audioPath: 'audios/春.mp3' },
    { id: 18, char: '蓝', pinyin: 'lán', meaning: '蓝色', emoji: '🔵', audioPath: 'audios/蓝.mp3' },
    { id: 19, char: '上', pinyin: 'shàng', meaning: '上面', emoji: '⬆️', audioPath: 'audios/上.mp3' },
    { id: 20, char: '东', pinyin: 'dōng', meaning: '东方', emoji: '🧭', audioPath: 'audios/东.mp3' },
    { id: 21, char: '火', pinyin: 'huǒ', meaning: '火焰', emoji: '🔥', audioPath: 'audios/火.mp3' },
    { id: 22, char: '光', pinyin: 'guāng', meaning: '光明', emoji: '✨', audioPath: 'audios/光.mp3' },
    
    // 身体篇 (23-42)
    { id: 23, char: '人', pinyin: 'rén', meaning: '人类', emoji: '🧑', audioPath: 'audios/人.mp3' },
    { id: 24, char: '大', pinyin: 'dà', meaning: '体积大', emoji: '🔷', audioPath: 'audios/大.mp3' },
    { id: 25, char: '保', pinyin: 'bǎo', meaning: '保护', emoji: '🛡️', audioPath: 'audios/保.mp3' },
    { id: 26, char: '女', pinyin: 'nǚ', meaning: '女性', emoji: '👩', audioPath: 'audios/女.mp3' },
    { id: 27, char: '长', pinyin: 'cháng', meaning: '长度', emoji: '📏', audioPath: 'audios/长.mp3' },
    { id: 28, char: '父', pinyin: 'fù', meaning: '父亲', emoji: '👨', audioPath: 'audios/父.mp3' },
    { id: 29, char: '天', pinyin: 'tiān', meaning: '天空', emoji: '🌌', audioPath: 'audios/天.mp3' },
    { id: 30, char: '目', pinyin: 'mù', meaning: '眼睛', emoji: '👁️', audioPath: 'audios/目.mp3' },
    { id: 31, char: '看', pinyin: 'kàn', meaning: '观看', emoji: '👀', audioPath: 'audios/看.mp3' },
    { id: 32, char: '口', pinyin: 'kǒu', meaning: '嘴巴', emoji: '👄', audioPath: 'audios/口.mp3' },
    { id: 33, char: '门', pinyin: 'mén', meaning: '门户', emoji: '🚪', audioPath: 'audios/门.mp3' },
    { id: 34, char: '耳', pinyin: 'ěr', meaning: '耳朵', emoji: '👂', audioPath: 'audios/耳.mp3' },
    { id: 35, char: '自', pinyin: 'zì', meaning: '自己', emoji: '🙋', audioPath: 'audios/自.mp3' },
    { id: 36, char: '手', pinyin: 'shǒu', meaning: '手掌', emoji: '✋', audioPath: 'audios/手.mp3' },
    { id: 37, char: '止', pinyin: 'zhǐ', meaning: '停止', emoji: '🛑', audioPath: 'audios/止.mp3' },
    { id: 38, char: '肉', pinyin: 'ròu', meaning: '肉体', emoji: '🥩', audioPath: 'audios/肉.mp3' },
    { id: 39, char: '问', pinyin: 'wèn', meaning: '询问', emoji: '❓', audioPath: 'audios/问.mp3' },
    { id: 40, char: '宫', pinyin: 'gōng', meaning: '宫殿', emoji: '🏰', audioPath: 'audios/宫.mp3' },
    { id: 41, char: '车', pinyin: 'chē', meaning: '车辆', emoji: '🚗', audioPath: 'audios/车.mp3' },
    { id: 42, char: '行', pinyin: 'xíng', meaning: '行走', emoji: '🚶', audioPath: 'audios/行.mp3' },
    
    // 日常篇 (43-48)
    { id: 43, char: '衣', pinyin: 'yī', meaning: '衣服', emoji: '👔', audioPath: 'audios/衣.mp3' },
    { id: 44, char: '巾', pinyin: 'jīn', meaning: '毛巾', emoji: '🧻', audioPath: 'audios/巾.mp3' },
    { id: 45, char: '贝', pinyin: 'bèi', meaning: '贝壳', emoji: '🐚', audioPath: 'audios/贝.mp3' },
    { id: 46, char: '沐', pinyin: 'mù', meaning: '沐浴', emoji: '🚿', audioPath: 'audios/沐.mp3' },
    { id: 47, char: '来', pinyin: 'lái', meaning: '来到', emoji: '➡️', audioPath: 'audios/来.mp3' },
    { id: 48, char: '行', pinyin: 'xíng', meaning: '行走', emoji: '🚶', audioPath: 'audios/行.mp3' }
  ]

  async aboutToAppear() {
    await this.setFullScreen()
    // 初始化音频服务
    await audioPlayService.initialize()
    // 初始化数据存储
    await this.initDataPreferences()
    // 加载当前组
    await this.loadCurrentGroup()
  }
  
  // 初始化数据存储
  async initDataPreferences() {
    try {
      const context = getContext(this) as common.UIAbilityContext
      this.dataPreferences = await preferences.getPreferences(context, 'listen_data')
      console.info('✅ ListenPage 数据存储初始化成功')
    } catch (err) {
      console.error('❌ ListenPage 数据存储初始化失败:', JSON.stringify(err))
    }
  }
  
  // 加载当前组的汉字
  async loadCurrentGroup() {
    try {
      if (this.dataPreferences) {
        // 读取已播放的组（用Set存储）
        const playedGroupsStr = await this.dataPreferences.get('played_groups', '[]') as string
        const playedGroups: number[] = JSON.parse(playedGroupsStr)
        
        console.info(`已播放的组: ${playedGroupsStr}`)
        
        // 找到第一个未播放的组
        let targetGroupIndex = 0
        for (let i = 0; i < this.TOTAL_GROUPS; i++) {
          if (!playedGroups.includes(i)) {
            targetGroupIndex = i
            break
          }
        }
        
        // 如果所有组都播放过了，重置为第一组
        if (playedGroups.length >= this.TOTAL_GROUPS) {
          targetGroupIndex = 0
          await this.dataPreferences.put('played_groups', '[]')
          await this.dataPreferences.flush()
          console.info('所有组已播放完，重置为第一组')
        }
        
        this.currentGroupIndex = targetGroupIndex
        console.info(`当前加载第 ${targetGroupIndex + 1} 组`)
      } else {
        this.currentGroupIndex = 0
      }
      
      // 加载对应组的汉字
      this.loadGroupAudios()
    } catch (err) {
      console.error('❌ 加载分组失败:', JSON.stringify(err))
      this.currentGroupIndex = 0
      this.loadGroupAudios()
    }
  }
  
  // 加载指定组的汉字
  loadGroupAudios() {
    const startIndex = this.currentGroupIndex * this.GROUP_SIZE
    const endIndex = Math.min(startIndex + this.GROUP_SIZE, this.allAudioList.length)
    this.displayAudioList = this.allAudioList.slice(startIndex, endIndex)
    this.currentIndex = 0
    console.info(`加载第 ${this.currentGroupIndex + 1} 组，共 ${this.displayAudioList.length} 个汉字`)
  }
  
  // 标记当前组为已播放
  async markGroupAsPlayed() {
    try {
      if (this.dataPreferences) {
        const playedGroupsStr = await this.dataPreferences.get('played_groups', '[]') as string
        const playedGroups: number[] = JSON.parse(playedGroupsStr)
        
        if (!playedGroups.includes(this.currentGroupIndex)) {
          playedGroups.push(this.currentGroupIndex)
          await this.dataPreferences.put('played_groups', JSON.stringify(playedGroups))
          await this.dataPreferences.flush()
          console.info(`标记第 ${this.currentGroupIndex + 1} 组为已播放`)
        }
      }
    } catch (err) {
      console.error('❌ 标记组失败:', JSON.stringify(err))
    }
  }

  aboutToDisappear() {
    // 清理音频资源
    audioPlayService.stop()
  }

  // 设置全屏沉浸式模式
  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage
      const mainWindow = await windowStage.getMainWindow()
      
      await mainWindow.setWindowLayoutFullScreen(true)
      await mainWindow.setWindowSystemBarEnable([])
      
      console.info('✅ ListenPage 全屏模式已启用')
    } catch (err) {
      console.error('❌ ListenPage 设置全屏失败:', JSON.stringify(err))
    }
  }

  // 播放当前汉字的音频
  async playCurrentAudio() {
    const currentAudio = this.displayAudioList[this.currentIndex]
    if (currentAudio && currentAudio.audioPath) {
      this.isPlaying = true
      await audioPlayService.playAudio(currentAudio.audioPath)
      
      // 如果是当前组的最后一个汉字，标记该组为已播放
      if (this.currentIndex === this.displayAudioList.length - 1) {
        await this.markGroupAsPlayed()
      }
      
      // 模拟播放完成后的状态更新
      setTimeout(() => {
        this.isPlaying = false
      }, 2000) // 假设音频播放2秒
    }
  }

  togglePlay() {
    if (this.isPlaying) {
      audioPlayService.stop()
      this.isPlaying = false
    } else {
      this.playCurrentAudio()
    }
  }

  previousAudio() {
    if (this.currentIndex > 0) {
      audioPlayService.stop()
      this.isPlaying = false
      this.currentIndex--
      this.playCurrentAudio()
    }
  }

  nextAudio() {
    if (this.currentIndex < this.displayAudioList.length - 1) {
      audioPlayService.stop()
      this.isPlaying = false
      this.currentIndex++
      this.playCurrentAudio()
    }
  }

  // 选择指定的组
  selectGroup(groupIndex: number) {
    this.currentGroupIndex = groupIndex
    this.loadGroupAudios()
    this.showGroupSelector = false
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
            ['#6a1b9a', 0.0],
            ['#8e24aa', 0.5],
            ['#ab47bc', 1.0]
          ]
        })

      // 横屏左右布局
      Row() {
        // 左侧：返回按钮和标题
        Column() {
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
          .margin({ bottom: 40 })
          .onClick(() => {
            router.back()
          })

          // 标题区域
          Column() {
            Row() {
              Text('🎧')
                .fontSize(36)
                .margin({ bottom: 8 })
            }

            Text('听一听')
              .fontSize(28)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })

            Text('标准发音')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.8)')
              .margin({ bottom: 4 })

            Text('跟读练习')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.8)')
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width(180)
        .height('100%')
        .padding({ left: 24, top: 24, bottom: 24 })
        .justifyContent(FlexAlign.Start)

        // 中间：主显示区
        Column() {
          // 大字显示
          Column() {
            if (this.displayAudioList.length > 0 && this.currentIndex < this.displayAudioList.length) {
              Text(this.displayAudioList[this.currentIndex].emoji)
                .fontSize(90)
                .margin({ bottom: 16 })

              Text(this.displayAudioList[this.currentIndex].char)
                .fontSize(120)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 12 })
                .animation({
                  duration: 2000,
                  iterations: -1,
                  curve: Curve.EaseInOut
                })
                .scale({ x: this.isPlaying ? 1.05 : 1, y: this.isPlaying ? 1.05 : 1 })

              Text(this.displayAudioList[this.currentIndex].pinyin)
                .fontSize(28)
                .fontColor('rgba(255, 255, 255, 0.9)')
                .margin({ bottom: 6 })

              Text(this.displayAudioList[this.currentIndex].meaning)
                .fontSize(15)
                .fontColor('rgba(255, 255, 255, 0.7)')
            }
          }
          .onClick(() => {
            this.playCurrentAudio()
          })
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 40 })

        // 右侧：控制按钮和进度
        Column() {
          // 进度指示（显示当前组信息，可点击选择）
          Text(`第${this.currentGroupIndex + 1}组 ${this.currentIndex + 1}/${this.displayAudioList.length}`)
            .fontSize(16)
            .fontColor('rgba(255, 255, 255, 0.8)')
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .borderRadius(16)
            .margin({ bottom: 40 })
            .onClick(() => {
              this.showGroupSelector = true
            })

          // 控制按钮（垂直排列）
          Column({ space: 20 }) {
            // 上一个
            Stack() {
              Column()
                .width(56)
                .height(56)
                .borderRadius(28)
                .backgroundColor('rgba(255, 255, 255, 0.2)')
                .backdropBlur(10)

              Text('⏮')
                .fontSize(24)
                .fontColor(Color.White)
            }
            .opacity(this.currentIndex === 0 ? 0.5 : 1)
            .onClick(() => {
              this.previousAudio()
            })

            // 播放/暂停
            Stack() {
              Column()
                .width(72)
                .height(72)
                .borderRadius(36)
                .linearGradient({
                  angle: 135,
                  colors: [['#ec4899', 0], ['#be185d', 1]]
                })
                .shadow({
                  radius: 20,
                  color: 'rgba(236, 72, 153, 0.5)',
                  offsetX: 0,
                  offsetY: 4
                })

              Text(this.isPlaying ? '⏸' : '▶️')
                .fontSize(32)
                .fontColor(Color.White)
            }
            .onClick(() => {
              this.togglePlay()
            })

            // 下一个
            Stack() {
              Column()
                .width(56)
                .height(56)
                .borderRadius(28)
                .backgroundColor('rgba(255, 255, 255, 0.2)')
                .backdropBlur(10)

              Text('⏭')
                .fontSize(24)
                .fontColor(Color.White)
            }
            .opacity(this.currentIndex === this.displayAudioList.length - 1 ? 0.5 : 1)
            .onClick(() => {
              this.nextAudio()
            })
          }
        }
        .width(180)
        .height('100%')
        .padding({ right: 24, top: 24, bottom: 24 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')

      // 分组选择器对话框
      if (this.showGroupSelector) {
        Stack() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.5)')
            .onClick(() => {
              this.showGroupSelector = false
            })

          // 对话框内容
          Column({ space: 20 }) {
            // 标题
            Text('选择分组')
              .fontSize(24)
              .fontColor('#1f2937')
              .fontWeight(FontWeight.Bold)

            // 分组列表
            Column({ space: 12 }) {
              ForEach([0, 1, 2, 3], (groupIndex: number) => {
                Stack() {
                  Column()
                    .width('100%')
                    .height(60)
                    .borderRadius(12)
                    .backgroundColor(this.currentGroupIndex === groupIndex ? '#ec4899' : Color.White)
                    .shadow({ radius: 10, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
                  
                  Text(`第${groupIndex + 1}组 (${groupIndex * this.GROUP_SIZE + 1}-${Math.min((groupIndex + 1) * this.GROUP_SIZE, this.allAudioList.length)})`)
                    .fontSize(18)
                    .fontColor(this.currentGroupIndex === groupIndex ? Color.White : '#1f2937')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .onClick(() => {
                  this.selectGroup(groupIndex)
                })
              })
            }
            .width('100%')

            // 关闭按钮
            Button('取消')
              .width('100%')
              .height(50)
              .fontSize(18)
              .fontColor('#6b7280')
              .backgroundColor('#e5e7eb')
              .borderRadius(12)
              .onClick(() => {
                this.showGroupSelector = false
              })
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
    }
    .width('100%')
    .height('100%')
  }
}

interface AudioInfo {
  id: number
  char: string
  pinyin: string
  meaning: string
  emoji: string
  audioPath: string
}
