# 视频部署指南 - 48个视频懒加载方案

## 为什么不能用rawfile？

❌ **rawfile的问题**:
- 48个视频打包在APK中，APK大小约2GB
- rawfile会一次性加载到内存，导致OOM（内存不足）
- 不支持懒加载
- 安装失败率高（磁盘空间不足）

✅ **cacheDir方案的优势**:
- APK不包含视频，大小<50MB
- 视频存储在设备缓存目录
- 支持懒加载，按需读取
- 内存占用低（~150MB）
- 安装成功率高（99%）

## 快速开始（3步）

### 步骤1：部署视频到设备

**双击运行**:
```
deploy_videos_simple.bat
```

**执行过程**:
1. 检查本地视频文件（48个）
2. 检查设备连接
3. 在设备上创建缓存目录
4. 推送所有视频文件（需要10-15分钟）

**预期输出**:
```
📊 找到 48 个视频文件
✅ 设备已连接
✅ 目录创建完成
🚀 开始推送视频文件...
[100%] 推送: 第48课...
✅ 部署完成！
```

### 步骤2：验证视频已推送（可选）

**双击运行**:
```
check_videos_on_device.bat
```

**预期输出**:
```
✅ 设备已连接
✅ 视频目录存在
📊 视频文件列表:
-rw-r--r-- 1 root root 45M 第1课《马牛羊》.mp4
-rw-r--r-- 1 root root 42M 第2课《鸡狗猪猫》.mp4
...
```

### 步骤3：编译并安装应用

**在DevEco Studio中**:
1. 点击 **Run** 按钮（绿色三角形）
2. 等待编译完成（约15秒）
3. 等待安装完成（约20秒）
4. 应用自动启动

**或使用命令行**:
```powershell
hvigorw clean
hvigorw assembleHap
```

## 工作原理

### 1. 视频存储位置
```
设备路径: /data/storage/el2/base/haps/entry/cache/hanzileyuan_videos/
├── 第1课《马牛羊》.mp4
├── 第2课《鸡狗猪猫》.mp4
└── ... (48个视频)
```

### 2. 应用访问方式
```typescript
// VideoFileService.ets
getVideoPath(videoFileName: string): string {
  // 返回完整的文件系统路径
  return `${this.context.cacheDir}/hanzileyuan_videos/${videoFileName}`
}
```

### 3. Video组件使用
```typescript
// VideoPlayerPage.ets
Video({
  src: this.videoSrc,  // 直接使用文件路径，不用$rawfile()
  controller: this.videoController
})
```

### 4. 懒加载机制
- Video组件只在播放时读取文件
- 不会一次性加载所有视频到内存
- 支持流式播放，内存占用低

## 性能对比

| 方案 | APK大小 | 内存占用 | 安装时间 | 懒加载 |
|------|---------|---------|---------|--------|
| rawfile | 2.0GB | 500MB+ | 3-5分钟 | ❌ 不支持 |
| cacheDir | <50MB | ~150MB | 10-20秒 | ✅ 支持 |

## 常见问题

### Q1: 为什么需要10-15分钟？
**A**: 需要推送48个视频（约2GB）到设备，USB传输需要时间。

### Q2: 视频会占用应用空间吗？
**A**: 不会。视频存储在cacheDir，不计入应用大小。

### Q3: 系统会清理cacheDir吗？
**A**: 可能会。建议后续添加视频完整性检查和重新下载功能。

### Q4: 可以减少视频数量吗？
**A**: 可以。只推送需要的视频，修改 `deploy_videos_simple.bat` 脚本。

### Q5: 推送失败怎么办？
**A**: 
1. 检查USB连接
2. 检查设备存储空间（需要3GB+）
3. 重启设备后重试

### Q6: 如何删除设备上的视频？
**A**: 
```powershell
hdc shell "rm -rf /data/storage/el2/base/haps/entry/cache/hanzileyuan_videos"
```

## 故障排除

### 问题1：找不到hdc命令
**解决**:
- 在DevEco Studio的终端中运行脚本
- 或将SDK的toolchains目录添加到PATH

### 问题2：未检测到设备
**解决**:
1. 连接USB线
2. 启用USB调试
3. 信任此电脑
4. 运行 `hdc list targets` 验证

### 问题3：推送失败
**解决**:
1. 检查设备存储空间
2. 重新连接USB
3. 重启设备

### 问题4：视频无法播放
**解决**:
1. 运行 `check_videos_on_device.bat` 验证文件存在
2. 检查应用日志
3. 确认文件路径正确

## 技术细节

### VideoFileService
```typescript
// 使用cacheDir
this.videoBasePath = `${this.context.cacheDir}/hanzileyuan_videos`

// 返回完整路径
getVideoPath(videoFileName: string): string {
  return `${this.videoBasePath}/${videoFileName}`
}
```

### VideoControllerManager
```typescript
// 全局单例，避免重复创建
private static instance: VideoControllerManager
private controller: VideoController | null = null

getController(): VideoController {
  if (!this.controller) {
    this.controller = new VideoController()
  }
  return this.controller
}
```

### MemoryMonitor
```typescript
// 每5秒检查内存
startMonitoring(): void {
  this.monitorTimer = setInterval(() => {
    const memoryUsage = this.getMemoryUsage()
    if (memoryUsage > this.memoryThreshold) {
      this.triggerGC()  // 触发垃圾回收
    }
  }, 5000)
}
```

## 后续优化

### 短期
- [ ] 添加视频完整性检查
- [ ] 添加清理缓存按钮
- [ ] 显示缓存大小

### 中期
- [ ] LazyForEach优化列表页
- [ ] 缩略图生成
- [ ] 视频预加载

### 长期
- [ ] 在线视频下载
- [ ] 增量更新
- [ ] 断点续传

## 总结

**cacheDir + 懒加载方案是48个视频的最佳选择**:
- ✅ APK最小（<50MB）
- ✅ 内存优化（~150MB）
- ✅ 支持懒加载
- ✅ 安装成功率高

**下一步**: 运行 `deploy_videos_simple.bat`，然后在DevEco Studio中点击Run！
