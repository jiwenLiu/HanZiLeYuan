/**
 * 内存监控服务
 * 监控内存使用情况，及时释放资源
 */
export class MemoryMonitor {
  private static instance: MemoryMonitor
  private monitorTimer: number = -1
  private memoryThreshold: number = 200 * 1024 * 1024 // 200MB阈值
  
  private constructor() {
    console.info('📊 MemoryMonitor 初始化')
  }
  
  static getInstance(): MemoryMonitor {
    if (!MemoryMonitor.instance) {
      MemoryMonitor.instance = new MemoryMonitor()
    }
    return MemoryMonitor.instance
  }
  
  /**
   * 开始监控内存
   */
  startMonitoring(callback?: (memoryUsage: number) => void): void {
    if (this.monitorTimer !== -1) {
      return
    }
    
    this.monitorTimer = setInterval(() => {
      const memoryUsage = this.getMemoryUsage()
      console.info(`💾 当前内存使用: ${(memoryUsage / 1024 / 1024).toFixed(2)} MB`)
      
      if (callback) {
        callback(memoryUsage)
      }
      
      // 如果超过阈值，触发GC
      if (memoryUsage > this.memoryThreshold) {
        console.warn(`⚠️ 内存使用超过阈值，触发GC`)
        this.triggerGC()
      }
    }, 5000) // 每5秒检查一次
  }
  
  /**
   * 停止监控
   */
  stopMonitoring(): void {
    if (this.monitorTimer !== -1) {
      clearInterval(this.monitorTimer)
      this.monitorTimer = -1
      console.info('⏹️ 内存监控已停止')
    }
  }
  
  /**
   * 获取当前内存使用（模拟）
   */
  private getMemoryUsage(): number {
    // HarmonyOS中可以使用 @ohos.app.ability.abilityManager 获取内存信息
    // 这里简化处理，返回估算值
    return 150 * 1024 * 1024 // 150MB
  }
  
  /**
   * 触发垃圾回收
   */
  triggerGC(): void {
    try {
      // 在HarmonyOS中，可以通过清理不必要的对象来触发GC
      // 这里记录日志，实际GC由系统自动管理
      console.info('🗑️ 建议系统进行垃圾回收')
    } catch (err) {
      console.error('❌ GC触发失败:', JSON.stringify(err))
    }
  }
  
  /**
   * 设置内存阈值
   */
  setThreshold(threshold: number): void {
    this.memoryThreshold = threshold
    console.info(`📊 内存阈值设置为: ${(threshold / 1024 / 1024).toFixed(2)} MB`)
  }
}
