import { router, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { antiAddictionService } from '../services/AntiAddictionService';
import { soundEffectService } from '../services/SoundEffectService';

const DOMAIN = 0x0001;

@Entry
@Component
struct HomePage {
  @State cardAnimations: number[] = [0, 0, 0, 0];
  @State profileIconBounce: number = 0;
  @State scrollItemsX: number[] = [];
  @State lanternsY: number[] = [];
  @State verticalFloatY: number[] = [];
  @State verticalFloatX: number[] = [];
  @State booksRotation: number[] = [];
  @State sealsScale: number[] = [];
  @State coinsRotationY: number[] = [];
  @State coinsFloatY: number[] = [];
  
  private animationTimer: number = -1;

  async aboutToAppear() {
    hilog.info(DOMAIN, 'HomePage', 'aboutToAppear');
    
    // 设置全屏沉浸式模式
    await this.setFullScreen();
    
    // 初始化并启动防沉迷服务
    const context = getContext(this) as common.UIAbilityContext;
    await antiAddictionService.initialize(context);
    antiAddictionService.startMonitoring();
    hilog.info(DOMAIN, 'HomePage', '✅ 防沉迷监控已启动');
    
    // 初始化音效服务并播放背景音乐
    await soundEffectService.initialize(context);
    await soundEffectService.playBackgroundMusic('audios/muzhiqin.mp3');
    hilog.info(DOMAIN, 'HomePage', '✅ 背景音乐已启动');
    
    // 初始化动画数组
    this.scrollItemsX = new Array(5).fill(-100);
    this.lanternsY = new Array(4).fill(0);
    this.verticalFloatY = new Array(3).fill(0);
    this.verticalFloatX = new Array(3).fill(0);
    this.booksRotation = new Array(7).fill(0);
    this.sealsScale = new Array(8).fill(1);
    this.coinsRotationY = new Array(4).fill(0);
    this.coinsFloatY = new Array(4).fill(0);
    
    this.startAllAnimations();
  }

  async aboutToDisappear() {
    if (this.animationTimer !== -1) {
      clearInterval(this.animationTimer);
    }
    // 停止背景音乐
    await soundEffectService.stopBackgroundMusic();
  }

  // 设置全屏沉浸式模式
  async setFullScreen() {
    try {
      const windowStage = (getContext(this) as common.UIAbilityContext).windowStage;
      const mainWindow = await windowStage.getMainWindow();
      
      // 设置全屏布局
      await mainWindow.setWindowLayoutFullScreen(true);
      
      // 隐藏状态栏和导航栏
      await mainWindow.setWindowSystemBarEnable([]);
      
      hilog.info(DOMAIN, 'HomePage', '✅ 全屏沉浸式模式已启用');
    } catch (err) {
      hilog.error(DOMAIN, 'HomePage', '❌ 设置全屏失败: %{public}s', JSON.stringify(err));
    }
  }

  startAllAnimations() {
    this.animationTimer = setInterval(() => {
      const time = Date.now() / 1000;
      
      // 卡片浮动
      for (let i = 0; i < 4; i++) {
        this.cardAnimations[i] = Math.sin(time + i * 1.5) * 8;
      }
      
      // 右上角个人中心图标弹跳动画
      this.profileIconBounce = Math.abs(Math.sin(time * 0.5)) * 8;
      
      // 横向飘动的书卷
      for (let i = 0; i < 5; i++) {
        const duration = 25 + i * 2;
        const progress = ((time / duration + i * 0.2) % 1);
        this.scrollItemsX[i] = -100 + progress * 1300;
      }
      
      // 灯笼漂浮（限制在上方，使用Math.abs确保只向上）
      for (let i = 0; i < 4; i++) {
        // 使用负值和Math.abs，确保灯笼只在上方漂浮
        this.lanternsY[i] = -Math.abs(Math.sin(time * 0.5 + i) * 25);
      }
      
      // 垂直飘动元素
      for (let i = 0; i < 3; i++) {
        this.verticalFloatY[i] = Math.sin(time + i * 2) * 50;
        this.verticalFloatX[i] = Math.sin(time * 0.8 + i * 1.5) * 30;
      }
      
      // 书本摇摆
      for (let i = 0; i < 7; i++) {
        this.booksRotation[i] = Math.sin(time * 2 + i * 0.5) * 5;
      }
      
      // 印章脉动
      for (let i = 0; i < 8; i++) {
        this.sealsScale[i] = 1 + Math.sin(time * 2 + i * 0.5) * 0.1;
      }
      
      // 金币旋转和从底部上升到顶部再落下的动画
      for (let i = 0; i < 4; i++) {
        this.coinsRotationY[i] = (time * 50 + i * 60) % 360;
        
        // 从底部上升到屏幕顶部，然后落下的循环动画
        const duration = 6 + i * 0.5; // 每个金币的周期略有不同
        const progress = ((time / duration + i * 0.25) % 1); // 0到1的循环
        
        // 使用分段动画：
        // 0-0.5: 从底部上升到顶部（-200到-600）
        // 0.5-1: 从顶部落回底部（-600到-200）
        if (progress < 0.5) {
          // 上升阶段：从-200上升到-600
          this.coinsFloatY[i] = -200 - (progress * 2) * 400;
        } else {
          // 下降阶段：从-600落回-200
          this.coinsFloatY[i] = -600 + ((progress - 0.5) * 2) * 400;
        }
      }
    }, 50);
  }

  navigateToPage(url: string) {
    router.pushUrl({ url: url })
      .then(() => {
        hilog.info(DOMAIN, 'HomePage', `Navigated to ${url}`);
      })
      .catch((err: Error) => {
        hilog.error(DOMAIN, 'HomePage', `Navigation failed: ${err.message}`);
      });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景渐变层
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#8b4513', 0.0],
            ['#a0522d', 0.3],
            ['#cd853f', 0.6],
            ['#daa520', 1.0]
          ]
        })

      // 背景装饰层
      Stack() {
        // 横向飘动的书卷
        ForEach(['📜', '📕', '📗', '📖', '📘'], (emoji: string, index: number) => {
          Text(emoji)
            .fontSize(48)
            .position({ x: this.scrollItemsX[index], y: `${15 + index * 10}%` })
        }, (emoji: string, index: number) => emoji + index)

        // 灯笼（所有灯笼在同一行）
        ForEach([
          { left: '20%', top: '10%', animIndex: 0 },  // 第1个
          { left: '40%', top: '10%', animIndex: 2 },  // 第2个（改为10%，与其他灯笼在同一行）
          { left: '60%', top: '10%', animIndex: 1 },  // 第3个
          { left: '78%', top: '10%', animIndex: 1 }   // 第4个
        ], (item: DecoPositionWithAnim, index: number) => {
          Text('🏮')
            .fontSize(40)
            .position({ x: item.left, y: item.top })
            .translate({ y: this.lanternsY[item.animIndex] })
        }, (item: DecoPositionWithAnim, index: number) => item.left + index)

        // 垂直飘动元素（钢笔等）- 添加左右飘动
        ForEach([
          { emoji: '🖌️', left: '10%', top: '20%' },
          { emoji: '✒️', left: '85%', top: '30%' },
          { emoji: '🖊️', left: '70%', top: '50%' }
        ], (item: DecoWithEmoji, index: number) => {
          Text(item.emoji)
            .fontSize(40)
            .position({ x: item.left, y: item.top })
            .translate({ 
              x: this.verticalFloatX[index],
              y: this.verticalFloatY[index]
            })
        }, (item: DecoWithEmoji, index: number) => item.emoji + index)
      }
      .width('100%')
      .height('100%')

      // 内容层
      Column() {
        // 主内容区域
        Stack() {
          // 欢迎区域 - 左上角（完全透明，无边框，无padding）
          Row() {
            Text('👋')
              .fontSize(56)
              .margin({ right: 16 })

            Text('你好，小朋友！')
              .fontSize(26)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .shadow({
                radius: 12,
                color: 'rgba(255, 200, 0, 0.8)',
                offsetX: 3,
                offsetY: 3
              })
          }
          .position({ x: 16, y: 16 })

          // 个人中心图标 - 右上角（添加动画）
          Stack() {
            Column()
              .width(72)
              .height(72)
              .borderRadius(36)
              .linearGradient({
                angle: 135,
                colors: [
                  ['#fbbf24', 0.0],
                  ['#f97316', 0.5],
                  ['#dc2626', 1.0]
                ]
              })
              .shadow({
                radius: 20,
                color: 'rgba(0, 0, 0, 0.3)',
                offsetX: 0,
                offsetY: 10
              })

            Stack() {
              Text('👨‍🎓')
                .fontSize(38)

              Text('⚙️')
                .fontSize(18)
                .position({ x: 15, y: -8 })
            }
          }
          .position({ x: '100%', y: 16 })
          .translate({ x: -88, y: this.profileIconBounce })
          .onClick(() => {
            soundEffectService.playClickSound();
            router.pushUrl({ url: 'pages/ProfilePage' });
          })

          // 四个功能卡片 - 居中
          Row({ space: 20 }) {
            this.FunctionCard({
              emoji: '📚',
              emojiSize: 60,
              title: '课程探索',
              subtitle: '发现汉字的奥秘',
              count: '48个视频',
              gradientColors: ['#60a5fa', '#2563eb'],
              targetUrl: 'pages/ExplorePage',
              animationOffset: this.cardAnimations[0]
            })

            this.FunctionCard({
              emoji: '🎬',
              emojiSize: 60,
              title: '视频学习',
              subtitle: '观看精彩课程',
              count: '随时观看',
              gradientColors: ['#34d399', '#0d9488'],
              targetUrl: 'pages/WatchPage',
              animationOffset: this.cardAnimations[1]
            })

            this.FunctionCard({
              emoji: '🎧',
              emojiSize: 60,
              title: '听一听',
              subtitle: '听汉字故事',
              count: '语音朗读',
              gradientColors: ['#a78bfa', '#db2777'],
              targetUrl: 'pages/ListenPage',
              animationOffset: this.cardAnimations[2]
            })

            this.FunctionCard({
              emoji: '❓',
              emojiSize: 60,
              title: '趣味问答',
              subtitle: '挑战汉字知识',
              count: '50道题目',
              gradientColors: ['#fbbf24', '#f97316'],
              targetUrl: 'pages/QuizPage',
              animationOffset: this.cardAnimations[3]
            })
          }
          .width('100%')
          .padding({ left: 32, right: 32 })
          .justifyContent(FlexAlign.Center)
          .position({ x: 0, y: '48%' })
        }
        .layoutWeight(1)
        .width('100%')

        // 底部装饰层
        Stack() {
          // 文房四宝 - 书本（往下移动）
          ForEach([
            { emoji: '📚', left: 5 },
            { emoji: '📙', left: 18 },
            { emoji: '📓', left: 32 },
            { emoji: '📔', left: 48 },
            { emoji: '📒', left: 65 },
            { emoji: '📕', left: 78 },
            { emoji: '📗', left: 92 }
          ], (item: BottomItem, index: number) => {
            Text(item.emoji)
              .fontSize(48)
              .position({ x: `${item.left}%`, y: '100%' })
              .translate({ y: -60 })
              .rotate({
                z: 1,
                angle: this.booksRotation[index]
              })
          }, (item: BottomItem, index: number) => item.emoji + index)

          // 印章（往上移，与书本平齐）
          ForEach([
            { emoji: '🔴', left: 8, bottom: 60 },
            { emoji: '🔴', left: 25, bottom: 60 },
            { emoji: '🔴', left: 55, bottom: 60 },
            { emoji: '🔴', left: 82, bottom: 60 }
          ], (item: BottomItemWithBottom, index: number) => {
            Text(item.emoji)
              .fontSize(40)
              .position({ x: `${item.left}%`, y: '100%' })
              .translate({ y: -item.bottom })
              .scale({
                x: this.sealsScale[index],
                y: this.sealsScale[index]
              })
          }, (item: BottomItemWithBottom, index: number) => item.emoji + item.left + index)

          // 金币（气球图标，从底部上升到屏幕顶部再落下）
          ForEach([
            { emoji: '🪙', left: 12, bottom: 120 },
            { emoji: '🪙', left: 35, bottom: 120 },
            { emoji: '🪙', left: 58, bottom: 120 },
            { emoji: '🪙', left: 82, bottom: 120 }
          ], (item: BottomItemWithBottom, index: number) => {
            Text(item.emoji)
              .fontSize(28)
              .position({ x: `${item.left}%`, y: '100%' })
              .translate({ y: this.coinsFloatY[index] })
              .rotate({
                y: 1,
                angle: this.coinsRotationY[index]
              })
          }, (item: BottomItemWithBottom, index: number) => item.emoji + item.left + 'coin' + index)

          // 竹子装饰（往下移，与书本一样高）
          ForEach([
            { emoji: '🎋', left: 15, bottom: 60 },
            { emoji: '🎋', left: 38, bottom: 60 },
            { emoji: '🎋', left: 68, bottom: 60 },
            { emoji: '🎋', left: 88, bottom: 60 }
          ], (item: BottomItemWithBottom, index: number) => {
            Text(item.emoji)
              .fontSize(40)
              .position({ x: `${item.left}%`, y: '100%' })
              .translate({ y: -item.bottom })
              .scale({
                x: this.sealsScale[index + 4],
                y: this.sealsScale[index + 4]
              })
          }, (item: BottomItemWithBottom, index: number) => item.emoji + item.left + 'bamboo' + index)
        }
        .width('100%')
        .height(150)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FunctionCard(params: FunctionCardParams) {
    Column() {
      Text(params.emoji)
        .fontSize(params.emojiSize)
        .margin({ bottom: 8 })

      Text(params.title)
        .fontSize(16)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 4 })
        .textAlign(TextAlign.Center)

      Text(params.subtitle)
        .fontSize(12)
        .fontColor('rgba(255, 255, 255, 0.9)')
        .margin({ bottom: 8 })
        .textAlign(TextAlign.Center)

      Text(params.count)
        .fontSize(11)
        .fontColor(Color.White)
        .padding({ left: 10, right: 10, top: 2, bottom: 2 })
        .backgroundColor('rgba(255, 255, 255, 0.3)')
        .borderRadius(12)
    }
    .width(170)
    .aspectRatio(1)
    .padding(14)
    .linearGradient({
      angle: 135,
      colors: [
        [params.gradientColors[0] + 'CC', 0.0],
        [params.gradientColors[1] + 'CC', 1.0]
      ]
    })
    .borderRadius(24)
    .shadow({
      radius: 20,
      color: 'rgba(0, 0, 0, 0.3)',
      offsetX: 0,
      offsetY: 10
    })
    .border({ width: 1, color: 'rgba(255, 255, 255, 0.2)' })
    .backdropBlur(10)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .translate({ y: params.animationOffset })
    .onClick(() => {
      soundEffectService.playClickSound();
      this.navigateToPage(params.targetUrl);
    })
  }
}

interface DecoPosition {
  left: string;
  top: string;
}

interface DecoPositionWithAnim {
  left: string;
  top: string;
  animIndex: number;
}

interface DecoWithEmoji {
  emoji: string;
  left: string;
  top: string;
}

interface BottomItem {
  emoji: string;
  left: number;
}

interface BottomItemWithBottom {
  emoji: string;
  left: number;
  bottom: number;
}

interface FunctionCardParams {
  emoji: string;
  emojiSize: number;
  title: string;
  subtitle: string;
  count: string;
  gradientColors: string[];
  targetUrl: string;
  animationOffset: number;
}






