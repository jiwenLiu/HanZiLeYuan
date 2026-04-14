/**
 * 音效和背景音乐服务
 * 支持背景音乐循环播放和点击音效
 */
import { media } from '@kit.MediaKit';
import { Context } from '@kit.AbilityKit';
import resourceManager from '@ohos.resourceManager';
import { BusinessError } from '@ohos.base';

class SoundEffectService {
  private bgmPlayer: media.AVPlayer | null = null;
  private effectPlayer: media.AVPlayer | null = null;
  private context: Context | null = null;
  private isBgmPlaying: boolean = false;
  private isEffectPlaying: boolean = false;

  /**
   * 初始化服务
   */
  async initialize(context: Context): Promise<void> {
    this.context = context;
    console.log('音效服务初始化完成');
  }

  /**
   * 播放背景音乐（循环）
   */
  async playBackgroundMusic(audioPath: string): Promise<void> {
    if (!this.context || !audioPath) {
      console.warn('上下文或音频路径为空');
      return;
    }

    try {
      // 停止当前背景音乐
      await this.stopBackgroundMusic();

      // 获取文件描述符
      const fileDescriptor = await this.context.resourceManager.getRawFd(audioPath);

      // 创建AVPlayer
      this.bgmPlayer = await media.createAVPlayer();
      
      // 设置播放源
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      this.bgmPlayer.fdSrc = avFileDescriptor;

      // 设置循环播放
      this.bgmPlayer.loop = true;

      // 设置状态变化回调
      this.bgmPlayer.on('stateChange', async (state: string) => {
        switch (state) {
          case 'initialized':
            await this.bgmPlayer?.prepare();
            break;
          case 'prepared':
            await this.bgmPlayer?.play();
            break;
          case 'playing':
            this.isBgmPlaying = true;
            console.log('背景音乐开始播放');
            break;
          case 'stopped':
            this.isBgmPlaying = false;
            break;
          case 'error':
            console.error('背景音乐播放错误');
            this.isBgmPlaying = false;
            break;
        }
      });

      // 设置错误回调
      this.bgmPlayer.on('error', (error: BusinessError) => {
        console.error('背景音乐播放错误:', JSON.stringify(error));
        this.isBgmPlaying = false;
      });

    } catch (error) {
      console.error('播放背景音乐失败:', JSON.stringify(error));
    }
  }

  /**
   * 停止背景音乐
   */
  async stopBackgroundMusic(): Promise<void> {
    try {
      if (this.bgmPlayer) {
        const state = this.bgmPlayer.state;
        if (state === 'playing' || state === 'paused') {
          await this.bgmPlayer.stop();
        }
        if (state !== 'released') {
          this.bgmPlayer.release();
        }
        this.bgmPlayer = null;
        this.isBgmPlaying = false;
        console.log('背景音乐已停止');
      }
    } catch (error) {
      console.error('停止背景音乐失败:', JSON.stringify(error));
    }
  }

  /**
   * 播放点击音效
   */
  async playClickSound(): Promise<void> {
    if (!this.context) {
      return;
    }

    // 如果音效正在播放，先停止
    if (this.isEffectPlaying) {
      return; // 避免音效重叠
    }

    try {
      // 获取文件描述符
      const fileDescriptor = await this.context.resourceManager.getRawFd('audios/CartoonJumpUp.mp3');

      // 创建AVPlayer
      this.effectPlayer = await media.createAVPlayer();
      
      // 设置播放源
      const avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      this.effectPlayer.fdSrc = avFileDescriptor;

      // 设置状态变化回调
      this.effectPlayer.on('stateChange', async (state: string) => {
        switch (state) {
          case 'initialized':
            await this.effectPlayer?.prepare();
            break;
          case 'prepared':
            await this.effectPlayer?.play();
            break;
          case 'playing':
            this.isEffectPlaying = true;
            break;
          case 'completed':
            this.isEffectPlaying = false;
            this.releaseEffectPlayer();
            break;
          case 'error':
            this.isEffectPlaying = false;
            this.releaseEffectPlayer();
            break;
        }
      });

      // 设置错误回调
      this.effectPlayer.on('error', (error: BusinessError) => {
        console.error('音效播放错误:', JSON.stringify(error));
        this.isEffectPlaying = false;
        this.releaseEffectPlayer();
      });

    } catch (error) {
      console.error('播放音效失败:', JSON.stringify(error));
      this.isEffectPlaying = false;
    }
  }

  /**
   * 释放音效播放器
   */
  private releaseEffectPlayer(): void {
    try {
      if (this.effectPlayer) {
        const state = this.effectPlayer.state;
        if (state !== 'idle' && state !== 'released') {
          this.effectPlayer.release();
        }
        this.effectPlayer = null;
      }
    } catch (error) {
      console.error('释放音效播放器失败:', JSON.stringify(error));
    }
  }

  /**
   * 释放所有资源
   */
  async release(): Promise<void> {
    await this.stopBackgroundMusic();
    this.releaseEffectPlayer();
    console.log('音效服务已释放');
  }
}

// 创建全局单例
export const soundEffectService = new SoundEffectService();
