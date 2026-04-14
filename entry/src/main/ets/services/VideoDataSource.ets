/**
 * 视频数据源 - 用于LazyForEach懒加载
 */
export interface VideoInfo {
  id: string
  title: string
  subtitle: string
  emoji: string
  duration: string
  status?: string
  category?: string
}

export class VideoDataSource implements IDataSource {
  private videos: VideoInfo[] = []
  private listeners: DataChangeListener[] = []
  
  constructor(videos: VideoInfo[]) {
    this.videos = videos
  }
  
  totalCount(): number {
    return this.videos.length
  }
  
  getData(index: number): VideoInfo {
    return this.videos[index]
  }
  
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }
  
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener)
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }
  
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }
  
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }
  
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }
  
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }
  
  /**
   * 更新视频数据
   */
  updateVideos(videos: VideoInfo[]): void {
    this.videos = videos
    this.notifyDataReload()
  }
  
  /**
   * 更新单个视频状态
   */
  updateVideoStatus(index: number, status: string): void {
    if (index >= 0 && index < this.videos.length) {
      this.videos[index].status = status
      this.notifyDataChange(index)
    }
  }
}
