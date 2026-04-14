# 视频转码指南

## 问题说明

当前视频文件无法播放，错误代码：`5400102 - BusinessError`

**原因**：视频编码格式不兼容。HarmonyOS AVPlayer要求：
- **容器格式**：MP4
- **视频编码**：H.264 (AVC)
- **音频编码**：AAC

当前视频可能使用了H.265 (HEVC)或其他不兼容的编码格式。

---

## 解决方案：使用格式工厂转码

### 步骤1：下载并安装格式工厂
- 官网：http://www.pcfreetime.com/formatfactory/CN/index.html
- 或从其他可信来源下载

### 步骤2：批量转码视频

#### 2.1 打开格式工厂
1. 启动格式工厂软件
2. 点击左侧菜单的"视频" → "MP4"

#### 2.2 添加文件
1. 点击"添加文件"按钮
2. 选择 `D:\PC_test\Videos` 目录下的所有视频文件
3. 或者只选择以下15个需要的视频：
   - 第1课《马牛羊》.mp4
   - 第2课《鸡狗猪猫》.mp4
   - 第3课《鸟鱼虫万》.mp4
   - 第5课《木林森本末片》.mp4
   - 第6课《树桑桃松柳》.mp4
   - 第7课《米麦菜果瓜》.mp4
   - 第8课《水泉川州洲》.mp4
   - 第9课《河江湖海》.mp4
   - 第10课《厂石原源》.mp4
   - 第23课《人从众比北》.mp4
   - 第24课《大太立站交文美》.mp4
   - 第25课《保孙儿孩》.mp4
   - 第43课《衣裘表里被》.mp4
   - 第44课《巾布冠带》.mp4
   - 第45课《贝玉朋宝》.mp4

#### 2.3 配置输出设置
1. 点击"输出配置"按钮
2. 设置参数：
   - **视频编码器**：AVC(H264)
   - **音频编码器**：AAC
   - **视频比特率**：2000-4000 kbps（根据原视频质量选择）
   - **音频比特率**：128 kbps
   - **分辨率**：保持原始或选择 1280x720
   - **帧率**：25 fps 或 30 fps
3. 点击"确定"

#### 2.4 设置输出目录
1. 点击"改变"按钮
2. 选择输出目录，建议：`D:\PC_test\Videos_Converted`
3. 点击"确定"

#### 2.5 开始转码
1. 点击"确定"返回主界面
2. 点击工具栏的"开始"按钮
3. 等待转码完成（15个视频大约需要30-60分钟，取决于电脑性能）

---

## 步骤3：替换项目中的视频文件

转码完成后，运行以下PowerShell命令：

```powershell
# 1. 删除旧视频
Remove-Item "entry\src\main\resources\rawfile\videos\*.mp4" -Force

# 2. 复制转码后的视频
Copy-Item "D:\PC_test\Videos_Converted\第1课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第2课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第3课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第5课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第6课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第7课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第8课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第9课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第10课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第23课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第24课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第25课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第43课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第44课*.mp4" "entry\src\main\resources\rawfile\videos\"
Copy-Item "D:\PC_test\Videos_Converted\第45课*.mp4" "entry\src\main\resources\rawfile\videos\"

# 3. 验证复制结果
Get-ChildItem "entry\src\main\resources\rawfile\videos\*.mp4" | Select-Object Name
```

---

## 步骤4：重新编译和测试

```bash
# 编译项目
hvigorw assembleHap

# 安装到设备
hdc install entry/build/default/outputs/default/entry-default-signed.hap

# 查看日志
hdc shell hilog | grep VideoPlayer
```

---

## 使用FFmpeg转码（高级用户）

如果您熟悉命令行工具，也可以使用FFmpeg：

```bash
# 安装FFmpeg（如果未安装）
# Windows: 从 https://ffmpeg.org/download.html 下载

# 批量转码命令
cd D:\PC_test\Videos
mkdir ..\Videos_Converted

# 转码单个文件示例
ffmpeg -i "第1课《马牛羊》.mp4" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k "..\Videos_Converted\第1课《马牛羊》.mp4"

# 批量转码所有MP4文件
for %f in (*.mp4) do ffmpeg -i "%f" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k "..\Videos_Converted\%f"
```

**FFmpeg参数说明：**
- `-c:v libx264`：使用H.264编码器
- `-preset medium`：编码速度（可选：ultrafast, fast, medium, slow）
- `-crf 23`：质量控制（18-28，数值越小质量越高）
- `-c:a aac`：使用AAC音频编码器
- `-b:a 128k`：音频比特率128kbps

---

## 验证视频编码格式

转码后，可以使用以下工具验证编码格式：

### 方法1：使用MediaInfo
1. 下载MediaInfo：https://mediaarea.net/en/MediaInfo
2. 打开视频文件
3. 查看"Video"部分的"Format"应该显示"AVC"或"H.264"
4. 查看"Audio"部分的"Format"应该显示"AAC"

### 方法2：使用FFmpeg
```bash
ffmpeg -i "第1课《马牛羊》.mp4"
```
输出应该包含：
```
Video: h264 (High) ...
Audio: aac (LC) ...
```

---

## 常见问题

### Q1：转码后文件变大了？
A：这是正常的。H.264编码可能比H.265文件大，但兼容性更好。

### Q2：转码需要多长时间？
A：取决于视频时长和电脑性能。通常每个10-15分钟的视频需要5-10分钟转码。

### Q3：转码后画质下降？
A：适当提高比特率（如4000-6000 kbps）或降低CRF值（如20）可以提高画质。

### Q4：批量转码时出错？
A：检查文件名是否包含特殊字符，确保有足够的磁盘空间。

---

## 技术说明

### HarmonyOS AVPlayer支持的格式

| 类型 | 支持的格式 |
|------|-----------|
| 容器 | MP4, MKV, WebM, TS |
| 视频编码 | H.264 (AVC), H.265 (HEVC, 部分设备), VP8, VP9 |
| 音频编码 | AAC, MP3, FLAC, Vorbis, Opus |

**注意**：H.265支持取决于设备硬件。为确保兼容性，建议使用H.264。

### 错误代码说明

- `5400102`：操作不允许，通常是编码格式不支持
- `9001005`：文件描述符获取失败，通常是文件不存在或路径错误

---

## 下一步

1. ✅ 使用格式工厂转码15个视频文件
2. ✅ 将转码后的文件复制到项目
3. ✅ 重新编译并测试
4. ✅ 验证视频可以正常播放

**转码完成后，视频应该可以正常播放！** 🎬✨










