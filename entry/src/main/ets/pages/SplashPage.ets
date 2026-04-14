import { router, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';

const DOMAIN = 0x0001;

@Entry
@Component
struct SplashPage {
  @State floatingChars: FloatingChar[] = [];
  @State logoTranslateY: number = 0;
  @State loadingOpacity: number = 0.6;
  private timer: number = -1;
  private logoTimer: number = -1;
  private loadingTimer: number = -1;

  async aboutToAppear() {
    hilog.info(DOMAIN, 'SplashPage', 'aboutToAppear');
    
    // 设置全屏沉浸式模式
    await this.setFullScreen();
    
    // 初始化飘浮汉字 - 从底部向上飘
    this.floatingChars = [
      { char: '字', left: '10%', delay: 0, size: 60 },
      { char: '文', left: '30%', delay: 1000, size: 80 },
      { char: '学', left: '50%', delay: 2000, size: 50 },
      { char: '习', left: '70%', delay: 500, size: 70 },
      { char: '乐', left: '85%', delay: 1500, size: 55 }
    ];

    // Logo上下浮动动画（减小幅度避免超出屏幕）
    this.logoTimer = setInterval(() => {
      const time = Date.now() / 1000;
      this.logoTranslateY = Math.sin(time * 2) * 15;
    }, 50);

    // 加载文字闪烁动画
    this.loadingTimer = setInterval(() => {
      const time = Date.now() / 1000;
      this.loadingOpacity = 0.6 + Math.abs(Math.sin(time * 2)) * 0.4;
    }, 50);

    // 3秒后跳转到首页
    this.timer = setTimeout(() => {
      this.navigateToHome();
    }, 3000);
  }

  aboutToDisappear() {
    if (this.timer !== -1) {
      clearTimeout(this.timer);
    }
    if (this.logoTimer !== -1) {
      clearInterval(this.logoTimer);
    }
    if (this.loadingTimer !== -1) {
      clearInterval(this.loadingTimer);
    }
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
      
      hilog.info(DOMAIN, 'SplashPage', '✅ 全屏沉浸式模式已启用');
    } catch (err) {
      hilog.error(DOMAIN, 'SplashPage', '❌ 设置全屏失败: %{public}s', JSON.stringify(err));
    }
  }

  async navigateToHome() {
    try {
      await router.replaceUrl({ url: 'pages/HomePage' });
      hilog.info(DOMAIN, 'SplashPage', 'Navigated to HomePage successfully');
    } catch (err) {
      hilog.error(DOMAIN, 'SplashPage', 'Navigation to HomePage failed: %{public}s', JSON.stringify(err));
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景渐变 - 棕色到金色
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#8b4513', 0.0],  // 棕色
            ['#cd853f', 0.5],  // 秘鲁色
            ['#daa520', 1.0]   // 金色
          ]
        })

      // 飘浮的汉字 - 从底部向上飘
      ForEach(this.floatingChars, (item: FloatingChar) => {
        Text(item.char)
          .fontSize(32)
          .fontColor('rgba(255, 255, 255, 0.6)')
          .fontWeight(FontWeight.Bold)
          .width(item.size)
          .height(item.size)
          .borderRadius(item.size / 2)
          .backgroundColor('rgba(255, 215, 0, 0.2)')
          .textAlign(TextAlign.Center)
          .position({ x: item.left, y: '100%' })
          .animation({
            duration: 8000,
            iterations: -1,
            delay: item.delay,
            curve: Curve.EaseIn
          })
          .translate({ y: -600 })
          .scale({ x: 1.5, y: 1.5 })
          .opacity(0)
      }, (item: FloatingChar) => item.char + item.left)

      // 主内容区域 - 垂直居中并向下偏移
      Column() {
        // 顶部间距（向下移动）
        Column()
          .height(60)

        // Logo区域
        Column() {
          // 大圆形Logo（放大）
          Stack() {
            Column()
              .width(180)
              .height(180)
              .borderRadius(90)
              .linearGradient({
                angle: 135,
                colors: [
                  ['#fbbf24', 0.0],  // yellow-400
                  ['#ea580c', 1.0]   // orange-600
                ]
              })
              .shadow({
                radius: 40,
                color: 'rgba(0, 0, 0, 0.5)',
                offsetX: 0,
                offsetY: 10
              })

            Text('汉')
              .fontSize(80)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .margin({ bottom: 32 })
          .translate({ y: this.logoTranslateY })

          // 标题（字体再次缩小）
          Text('汉字乐园')
            .fontSize(36)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 12 })

          // 副标题
          Text('Chinese Character Garden')
            .fontSize(24)
            .fontColor('#fde68a')  // yellow-200
        }

        // 间距
        Column()
          .height(140)

        // 加载提示
        Column() {
          Row({ space: 8 }) {
            LoadingProgress()
              .width(24)
              .height(24)
              .color(Color.White)

            Text('正在加载...')
              .fontSize(20)
              .fontColor(Color.White)
              .opacity(this.loadingOpacity)
          }
          .margin({ bottom: 16 })

          Text('探索汉字的奇妙世界')
            .fontSize(14)
            .fontColor('#fcd34d')  // yellow-300
        }

        // 底部间距（确保不超出）
        Column()
          .height(40)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}

interface FloatingChar {
  char: string;
  left: string;
  delay: number;
  size: number;
}










