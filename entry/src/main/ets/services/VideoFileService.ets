import { common } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'

interface VideoFileInfo {
  size: number
  mode: number
}

/**
 * 视频文件服务
 * 使用沙箱目录方式（适合大文件）
 * 首次运行时从rawfile复制到沙箱目录
 */
export class VideoFileService {
  private static instance: VideoFileService
  private context: common.UIAbilityContext
  private videosDir: string = ''
  private isInitialized: boolean = false
  
  private constructor(context: common.UIAbilityContext) {
    this.context = context
    this.videosDir = `${context.filesDir}/videos`
    console.info('📁 VideoFileService 初始化（沙箱模式）')
    console.info(`📂 视频目录: ${this.videosDir}`)
  }
  
  static getInstance(context: common.UIAbilityContext): VideoFileService {
    if (!VideoFileService.instance) {
      VideoFileService.instance = new VideoFileService(context)
    }
    return VideoFileService.instance
  }
  
  /**
   * 初始化视频文件（首次运行时复制）
   */
  async initializeVideos(): Promise<boolean> {
    if (this.isInitialized) {
      console.info('✅ 视频已初始化，跳过')
      return true
    }
    
    try {
      // 检查视频目录是否存在
      try {
        fileIo.statSync(this.videosDir)
        console.info('✅ 视频目录已存在')
        this.isInitialized = true
        return true
      } catch {
        // 目录不存在，创建并复制视频
        console.info('📁 创建视频目录...')
        fileIo.mkdirSync(this.videosDir)
      }
      
      // 获取所有视频文件列表
      const videoList = this.getCoreVideoList()
      console.info(`📦 开始复制 ${videoList.length} 个视频文件...`)
      
      let successCount = 0
      for (const videoFileName of videoList) {
        try {
          await this.copyVideoToSandbox(videoFileName)
          successCount++
          console.info(`✅ [${successCount}/${videoList.length}] ${videoFileName}`)
        } catch (err) {
          console.error(`❌ 复制失败: ${videoFileName}`, JSON.stringify(err))
        }
      }
      
      this.isInitialized = true
      console.info(`🎉 视频初始化完成！成功: ${successCount}/${videoList.length}`)
      return successCount === videoList.length
    } catch (err) {
      console.error('❌ 初始化视频失败:', JSON.stringify(err))
      return false
    }
  }
  
  /**
   * 从rawfile复制视频到沙箱
   */
  private async copyVideoToSandbox(videoFileName: string): Promise<void> {
    const resourceMgr = this.context.resourceManager
    
    // 读取rawfile中的视频
    const rawfilePath = `videos/${videoFileName}`
    const fileData = await resourceMgr.getRawFileContent(rawfilePath)
    
    // 写入沙箱目录
    const sandboxPath = `${this.videosDir}/${videoFileName}`
    const file = fileIo.openSync(sandboxPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY)
    fileIo.writeSync(file.fd, fileData.buffer)
    fileIo.closeSync(file.fd)
    
    console.info(`✅ 复制完成: ${videoFileName} (${fileData.buffer.byteLength} 字节)`)
  }
  
  /**
   * 获取视频文件路径（沙箱目录）
   * @param videoFileName 视频文件名，例如: "第1课《马牛羊》.mp4"
   * @returns 沙箱目录的绝对路径
   */
  getVideoPath(videoFileName: string): string {
    const absolutePath = `${this.videosDir}/${videoFileName}`
    console.info(`🎬 视频绝对路径: ${absolutePath}`)
    return absolutePath
  }
  
  /**
   * 获取视频文件的fd路径（异步）
   * @param videoFileName 视频文件名
   * @returns fd://路径
   */
  async getVideoFdPath(videoFileName: string): Promise<string> {
    try {
      const path = `videos/${videoFileName}`
      const resourceMgr = this.context.resourceManager
      const fileData = await resourceMgr.getRawFd(path)
      const fdPath = `fd://${fileData.fd}?offset=${fileData.offset}&length=${fileData.length}`
      console.info(`🎬 视频FD路径: ${fdPath}`)
      return fdPath
    } catch (err) {
      console.error(`❌ 获取视频FD失败: ${videoFileName}`, JSON.stringify(err))
      return ''
    }
  }
  
  /**
   * 检查视频文件是否存在（沙箱目录）
   * @param videoFileName 视频文件名
   * @returns Promise<boolean>
   */
  async checkVideoExists(videoFileName: string): Promise<boolean> {
    try {
      const path = `${this.videosDir}/${videoFileName}`
      fileIo.statSync(path)
      return true
    } catch {
      return false
    }
  }
  
  /**
   * 获取视频文件信息
   * @param videoFileName 视频文件名
   * @returns 文件信息（大小、权限等）
   */
  async getVideoFileInfo(videoFileName: string): Promise<VideoFileInfo | null> {
    try {
      const path = `${this.videosDir}/${videoFileName}`
      const stat = fileIo.statSync(path)
      console.info(`📊 文件信息: 大小=${stat.size}字节, 权限=${stat.mode.toString(8)}`)
      const info: VideoFileInfo = { size: stat.size, mode: stat.mode }
      return info
    } catch (err) {
      console.error(`❌ 获取文件信息失败: ${videoFileName}`, JSON.stringify(err))
      return null
    }
  }
  
  /**
   * 获取视频基础路径（用于显示）
   */
  getVideoBasePath(): string {
    return this.videosDir
  }
  
  /**
   * 获取初始化状态
   */
  isVideosInitialized(): boolean {
    return this.isInitialized
  }
  
  /**
   * 获取已打包的核心视频列表（27个）
   */
  getCoreVideoList(): string[] {
    return [
      '第1课《马牛羊》.mp4',
      '第2课《鸡狗猪猫》.mp4',
      '第3课《鸟鱼虫万》.mp4',
      '第4课《羽飞习翔》.mp4',
      '第5课《木林森本末片》.mp4',
      '第6课《树桑桃松柳》.mp4',
      '第7课《米麦菜果瓜》.mp4',
      '第8课《水泉川州洲》.mp4',
      '第9课《河江湖海》.mp4',
      '第10课《厂石原源》.mp4',
      '第14课《日月晶星》.mp4',
      '第15课《时早晚》.mp4',
      '第16课《雨云雪》.mp4',
      '第18课《蓝青红黑白》.mp4',
      '第19课《上下内外》.mp4',
      '第20课《东西南北中》.mp4',
      '第21课《火炎灰赤燃灯》.mp4',
      '第22课《光明亮的闪》.mp4',
      '第23课《人从众比北》.mp4',
      '第24课《大太立站交文美》.mp4',
      '第25课《保孙儿孩》.mp4',
      '第26课《女好母每妇安》.mp4',
      '第29课《天元首页头发》.mp4',
      '第32课《口舌齿牙穿》.mp4',
      '第40课《宫堂室房家》.mp4',
      '第41课《车辇舟船》.mp4',
      '第42课《行道街市》.mp4'
    ]
  }
}
