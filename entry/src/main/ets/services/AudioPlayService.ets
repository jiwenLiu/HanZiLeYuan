/**
 * 音频播放服务类
 * 使用HarmonyOS媒体API播放rawfile中的音频文件
 */
import { media } from '@kit.MediaKit';
import { Context } from '@kit.AbilityKit';
import resourceManager from '@ohos.resourceManager';
import { BusinessError } from '@ohos.base';

class AudioPlayService {
  private audioPlayer: media.AVPlayer | null = null;
  private isInitialized: boolean = false;
  private isPlaying: boolean = false;

  /**
   * 初始化音频播放器（延迟初始化，在首次播放时创建）
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }
    // AVPlayer 在播放时创建，这里只标记为已初始化
    this.isInitialized = true;
    console.log('音频播放服务初始化完成');
  }

  /**
   * 播放指定的音频资源
   * @param audioPath rawfile路径，例如 'audios/ma.mp3'
   */
  async playAudio(audioPath: string): Promise<void> {
    if (!audioPath) {
      console.warn('音频路径为空');
      return;
    }

    try {
      // 先停止当前播放
      await this.stop();

      // 获取上下文
      let abilityContext: Context;
      try {
        const globalContext = getContext() as Context;
        if (!globalContext || !globalContext.resourceManager) {
          console.warn('无法获取上下文，音频播放失败');
          return;
        }
        abilityContext = globalContext;
      } catch (error) {
        console.warn('获取上下文失败，音频播放失败:', JSON.stringify(error));
        return;
      }

      // 使用getRawFd获取文件描述符
      let fileDescriptor: resourceManager.RawFileDescriptor;
      try {
        fileDescriptor = await abilityContext.resourceManager.getRawFd(audioPath);
      } catch (error) {
        console.warn(`音频文件不存在: ${audioPath}`, JSON.stringify(error));
        return;
      }

      // 创建AVPlayer
      this.audioPlayer = await media.createAVPlayer();
      
      // 设置播放源 - 使用fdSrc
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      this.audioPlayer.fdSrc = avFileDescriptor;

      // 设置状态变化回调
      this.audioPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
        switch (state) {
          case 'initialized':
            console.info('AVPlayer state initialized called.');
            // 准备播放
            await this.audioPlayer?.prepare();
            break;
          case 'prepared':
            console.info('AVPlayer state prepared called.');
            // 开始播放
            await this.audioPlayer?.play();
            break;
          case 'playing':
            console.info('AVPlayer state playing called.');
            this.isPlaying = true;
            break;
          case 'completed':
            console.info('AVPlayer state completed called.');
            this.isPlaying = false;
            this.release();
            break;
          case 'stopped':
            console.info('AVPlayer state stopped called.');
            this.isPlaying = false;
            break;
          case 'error':
            console.error('AVPlayer state error called.');
            this.isPlaying = false;
            this.release();
            break;
        }
      });

      // 设置错误回调
      this.audioPlayer.on('error', (error: BusinessError) => {
        console.error('音频播放错误:', JSON.stringify(error));
        this.isPlaying = false;
        this.release();
      });

      console.log('开始播放音频:', audioPath);
    } catch (error) {
      console.error('音频播放失败:', JSON.stringify(error));
      this.isPlaying = false;
      this.release();
    }
  }

  /**
   * 停止当前播放
   */
  async stop(): Promise<void> {
    try {
      if (this.audioPlayer) {
        const state = this.audioPlayer.state;
        if (state === 'playing' || state === 'paused') {
          await this.audioPlayer.stop();
        }
        this.isPlaying = false;
        console.log('音频播放已停止');
      }
    } catch (error) {
      console.error('停止音频播放失败:', JSON.stringify(error));
      this.isPlaying = false;
    }
  }

  /**
   * 释放音频资源
   */
  release(): void {
    try {
      if (this.audioPlayer) {
        const state = this.audioPlayer.state;
        if (state !== 'idle' && state !== 'released') {
          this.audioPlayer.release();
        }
        this.audioPlayer = null;
        this.isPlaying = false;
        console.log('音频播放服务已释放');
      }
    } catch (error) {
      console.error('释放音频播放服务失败:', JSON.stringify(error));
    }
  }

  /**
   * 检查音频服务是否可用
   */
  isAvailable(): boolean {
    return this.isInitialized;
  }

  /**
   * 检查是否正在播放
   */
  isPlayingStatus(): boolean {
    return this.audioPlayer !== null && this.audioPlayer.state === 'playing';
  }
}

// 创建全局单例
export const audioPlayService = new AudioPlayService();









