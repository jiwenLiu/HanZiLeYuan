import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 设置窗口为横屏模式并全屏显示
    windowStage.getMainWindow().then((windowClass: window.Window) => {
      try {
        // 设置横屏
        windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE);
        hilog.info(DOMAIN, 'testTag', 'Set landscape orientation successfully');
      } catch (err) {
        hilog.error(DOMAIN, 'testTag', 'Failed to set orientation. Cause: %{public}s', JSON.stringify(err));
      }

      try {
        // 设置全屏布局，内容延伸到状态栏区域
        windowClass.setWindowLayoutFullScreen(true);
        hilog.info(DOMAIN, 'testTag', 'Set fullscreen layout successfully');
      } catch (err) {
        hilog.error(DOMAIN, 'testTag', 'Failed to set fullscreen. Cause: %{public}s', JSON.stringify(err));
      }

      try {
        // 隐藏系统状态栏和导航栏
        windowClass.setWindowSystemBarEnable([]);
        hilog.info(DOMAIN, 'testTag', 'Hide system bar successfully');
      } catch (err) {
        hilog.error(DOMAIN, 'testTag', 'Failed to hide system bar. Cause: %{public}s', JSON.stringify(err));
      }
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'testTag', 'Failed to get main window. Cause: %{public}s', JSON.stringify(err));
    });

    windowStage.loadContent('pages/SplashPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}