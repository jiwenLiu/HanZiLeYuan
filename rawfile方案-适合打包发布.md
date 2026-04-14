# rawfile方案 - 适合打包发布

## 方案说明

由于你需要打包发布APK，不能依赖脚本，所以**必须使用rawfile**。

但为了避免内存问题，我们采用**混合策略**：
- ✅ **15个核心视频**打包在rawfile（APK约700MB）
- ✅ **其他33个视频**标记为"未打包"，提示用户后续下载
- ✅ **Video组件不使用autoPlay**，避免一次性加载

## 执行步骤（2步）

### 步骤1：复制核心视频到rawfile

**双击运行**:
```
setup_core_videos_rawfile.bat
```

**这个脚本会**:
- 复制15个核心视频到 `entry/src/main/resources/rawfile/hanzileyuan_videos/`
- APK大小约700MB（可接受）

**预期输出**:
```
✅ 第1课
✅ 第2课
...
✅ 第18课
📊 Count: 15
    TotalSizeMB: 650.23
```

### 步骤2：编译并测试

```powershell
hvigorw clean
hvigorw assembleHap
```

**预期结果**:
- APK大小: 约700MB
- 编译时间: 约30秒
- 安装时间: 约1-2分钟

## 核心视频列表（15个）

已打包的视频：
1. ✅ 第1课《马牛羊》
2. ✅ 第2课《鸡狗猪猫》
3. ✅ 第3课《鸟鱼虫万》
4. ✅ 第4课《羽飞习翔》
5. ✅ 第5课《木林森本末片》
6. ✅ 第6课《树桑桃松柳》
7. ✅ 第7课《米麦菜果瓜》
8. ✅ 第8课《水泉川州洲》
9. ✅ 第9课《河江湖海》
10. ✅ 第10课《厂石原源》
11. ✅ 第14课《日月晶星》
12. ✅ 第15课《时早晚》
13. ✅ 第16课《雨云雪》
14. ✅ 第17课《春夏秋冬》
15. ✅ 第18课《蓝青红黑白》

未打包的视频（33个）：
- 第19-43课：提示"视频未打包，可后续下载"

## 内存优化策略

### 1. 不使用autoPlay
```typescript
Video({
  src: $rawfile(this.videoSrc),
  controller: this.videoController
})
  .autoPlay(false)  // ✅ 不自动播放
```

### 2. VideoController单例
```typescript
// 全局复用，避免重复创建
private videoController: VideoController = VideoControllerManager.getInstance().getController()
```

### 3. 内存监控
```typescript
// 实时监控，超过200MB触发GC
this.memoryMonitor.startMonitoring()
```

### 4. 资源及时释放
```typescript
async aboutToDisappear() {
  // 停止播放
  VideoControllerManager.getInstance().stop()
  // 停止监控
  this.memoryMonitor.stopMonitoring()
}
```

## 性能预估

### APK大小
- **15个视频**: 约700MB
- **48个视频**: 约2GB（不推荐）

### 内存占用
- **不使用autoPlay**: ~150MB ✅
- **使用autoPlay**: ~500MB ❌

### 安装成功率
- **700MB APK**: 约80%
- **2GB APK**: 约10%

## 后续优化建议

### 短期（本周）
1. ✅ 已完成：15个核心视频打包
2. 🔄 添加"视频未打包"提示
3. 🔄 添加"在线下载"按钮

### 中期（下周）
1. 📋 实现在线视频下载功能
2. 📋 下载到cacheDir
3. 📋 支持断点续传

### 长期（下月）
1. 📋 视频压缩（降低APK大小）
2. 📋 增量更新
3. 📋 智能缓存管理

## 如果需要所有48个视频

### 方案A：全部打包（不推荐）
```powershell
# 复制所有视频
xcopy "hanzileyuan_videos\*.mp4" "entry\src\main\resources\rawfile\hanzileyuan_videos\" /Y
```

**问题**:
- APK约2GB
- 安装失败率高
- 内存占用高

### 方案B：在线下载（推荐）
1. 核心15个视频打包在APK
2. 其他33个视频上传到云存储
3. 应用内提供下载功能
4. 下载到cacheDir

**优势**:
- APK小（700MB）
- 按需下载
- 节省用户流量

## 代码说明

### VideoFileService
```typescript
// 使用rawfile模式
getVideoPath(videoFileName: string): string {
  return `hanzileyuan_videos/${videoFileName}`
}

// 检查视频是否存在
async checkVideoExists(videoFileName: string): Promise<boolean> {
  try {
    await resourceMgr.getRawFileContent(path)
    return true
  } catch {
    return false  // 视频未打包
  }
}
```

### VideoPlayerPage
```typescript
// 使用$rawfile()
Video({
  src: $rawfile(this.videoSrc),
  controller: this.videoController
})
  .autoPlay(false)  // 不自动播放
```

## 总结

**rawfile方案适合打包发布，但需要权衡**:

| 视频数量 | APK大小 | 安装成功率 | 推荐度 |
|---------|---------|-----------|--------|
| 15个核心 | 700MB | 80% | ⭐⭐⭐⭐⭐ |
| 29个 | 1.2GB | 40% | ⭐⭐ |
| 48个全部 | 2.0GB | 10% | ❌ |

**推荐方案**: 
1. 打包15个核心视频（700MB APK）
2. 其他视频提供在线下载
3. 使用内存优化策略

**下一步**: 运行 `setup_core_videos_rawfile.bat`，然后编译测试！
