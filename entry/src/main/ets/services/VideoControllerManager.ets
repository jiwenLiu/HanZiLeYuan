/**
 * VideoController单例管理器
 * 全局复用VideoController，避免重复创建占用内存
 */
export class VideoControllerManager {
  private static instance: VideoControllerManager
  private controller: VideoController | null = null
  
  private constructor() {
    console.info('🎮 VideoControllerManager 初始化')
  }
  
  static getInstance(): VideoControllerManager {
    if (!VideoControllerManager.instance) {
      VideoControllerManager.instance = new VideoControllerManager()
    }
    return VideoControllerManager.instance
  }
  
  /**
   * 获取全局VideoController
   */
  getController(): VideoController {
    if (!this.controller) {
      this.controller = new VideoController()
      console.info('✅ VideoController 创建成功')
    }
    return this.controller
  }
  
  /**
   * 停止播放
   */
  stop(): void {
    if (this.controller) {
      this.controller.stop()
      console.info('⏹️ VideoController 停止播放')
    }
  }
  
  /**
   * 暂停播放
   */
  pause(): void {
    if (this.controller) {
      this.controller.pause()
      console.info('⏸️ VideoController 暂停播放')
    }
  }
  
  /**
   * 释放资源
   */
  release(): void {
    if (this.controller) {
      this.controller.stop()
      this.controller = null
      console.info('🗑️ VideoController 资源释放')
    }
  }
}
