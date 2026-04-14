import preferences from '@ohos.data.preferences'
import { common } from '@kit.AbilityKit'
import promptAction from '@ohos.promptAction'
import { router } from '@kit.ArkUI'

/**
 * 防沉迷服务
 * 负责监控应用使用时长，超时后提醒用户休息
 */
class AntiAddictionService {
  private dataPreferences: preferences.Preferences | null = null
  private startTime: number = 0
  private checkTimer: number = -1
  private limitMinutes: number = 30  // 默认30分钟
  private isInitialized: boolean = false
  private hasWarned: boolean = false

  /**
   * 初始化服务
   */
  async initialize(context: common.UIAbilityContext): Promise<void> {
    if (this.isInitialized) {
      return
    }

    try {
      this.dataPreferences = await preferences.getPreferences(context, 'anti_addiction_data')
      await this.loadSettings()
      this.isInitialized = true
      console.info('✅ 防沉迷服务初始化成功')
    } catch (err) {
      console.error('❌ 防沉迷服务初始化失败:', JSON.stringify(err))
    }
  }

  /**
   * 加载设置
   */
  async loadSettings(): Promise<void> {
    try {
      if (this.dataPreferences) {
        this.limitMinutes = await this.dataPreferences.get('limitMinutes', 30) as number
        console.info(`防沉迷时长设置: ${this.limitMinutes}分钟`)
      }
    } catch (err) {
      console.error('加载防沉迷设置失败:', JSON.stringify(err))
    }
  }

  /**
   * 保存设置
   */
  async saveSettings(minutes: number): Promise<void> {
    try {
      if (this.dataPreferences && minutes > 0) {
        await this.dataPreferences.put('limitMinutes', minutes)
        await this.dataPreferences.flush()
        this.limitMinutes = minutes
        console.info(`防沉迷时长已更新: ${minutes}分钟`)
      }
    } catch (err) {
      console.error('保存防沉迷设置失败:', JSON.stringify(err))
    }
  }

  /**
   * 获取当前设置的时长
   */
  getLimitMinutes(): number {
    return this.limitMinutes
  }

  /**
   * 开始监控
   */
  startMonitoring(): void {
    if (!this.isInitialized) {
      console.warn('防沉迷服务未初始化')
      return
    }

    this.startTime = Date.now()
    this.hasWarned = false

    // 每分钟检查一次
    this.checkTimer = setInterval(() => {
      this.checkUsageTime()
    }, 60000)  // 60秒检查一次

    console.info('✅ 防沉迷监控已启动')
  }

  /**
   * 停止监控
   */
  stopMonitoring(): void {
    if (this.checkTimer !== -1) {
      clearInterval(this.checkTimer)
      this.checkTimer = -1
      console.info('防沉迷监控已停止')
    }
  }

  /**
   * 检查使用时长
   */
  private checkUsageTime(): void {
    const currentTime = Date.now()
    const usedMinutes = Math.floor((currentTime - this.startTime) / 60000)

    console.info(`已使用时长: ${usedMinutes}分钟 / ${this.limitMinutes}分钟`)

    // 提前5分钟提醒
    if (usedMinutes >= this.limitMinutes - 5 && usedMinutes < this.limitMinutes && !this.hasWarned) {
      this.showWarning(`还有5分钟就要休息啦！已使用${usedMinutes}分钟`)
      this.hasWarned = true
    }

    // 达到时长限制
    if (usedMinutes >= this.limitMinutes) {
      this.showTimeUpDialog(usedMinutes)
    }
  }

  /**
   * 显示警告提示
   */
  private showWarning(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 3000
    })
  }

  /**
   * 显示时间到对话框
   */
  private showTimeUpDialog(usedMinutes: number): void {
    this.stopMonitoring()

    promptAction.showDialog({
      title: '休息时间到啦！',
      message: `你已经学习了${usedMinutes}分钟，该休息一下保护眼睛啦！\n\n建议：\n• 远眺窗外5-10分钟\n• 做做眼保健操\n• 喝点水，活动一下`,
      buttons: [
        { text: '知道了', color: '#10b981' }
      ]
    }).then(() => {
      // 用户点击后返回首页
      router.replaceUrl({ url: 'pages/HomePage' })
    }).catch((err: Error) => {
      console.error('显示对话框失败:', JSON.stringify(err))
    })
  }

  /**
   * 重置计时器
   */
  reset(): void {
    this.startTime = Date.now()
    this.hasWarned = false
    console.info('防沉迷计时器已重置')
  }

  /**
   * 获取已使用时长（分钟）
   */
  getUsedMinutes(): number {
    if (this.startTime === 0) {
      return 0
    }
    return Math.floor((Date.now() - this.startTime) / 60000)
  }

  /**
   * 释放资源
   */
  release(): void {
    this.stopMonitoring()
    this.dataPreferences = null
    this.isInitialized = false
    console.info('防沉迷服务已释放')
  }
}

// 导出单例
export const antiAddictionService = new AntiAddictionService()








