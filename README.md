# ImageCompress

一个现代化的 macOS 图片压缩工具,完全免费开源。

## ✨ 特性

- 🎨 **现代化界面** - 使用 SwiftUI 打造的原生 macOS 应用
- 🖼️ **多格式支持** - 支持 PNG、JPG、GIF、WebP、HEIC 等格式
- ⚡ **批量处理** - 拖拽文件夹即可批量压缩
- 📊 **实时预览** - 压缩前后对比,所见即所得
- 🔒 **隐私安全** - 本地处理,不上传任何数据
- 💯 **完全免费** - 开源项目,永久免费

## 🚀 快速开始

### 系统要求

- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本

### 构建步骤

1. 克隆仓库
```bash
git clone https://github.com/yourusername/ImageCompress.git
cd ImageCompress
```

2. 打开 Xcode 项目
```bash
open ImageCompress.xcodeproj
```

3. 选择目标设备并运行
   - 选择 "My Mac" 作为目标
   - 点击运行按钮 (⌘R)

## 📖 使用说明

1. **拖拽图片** - 将图片或文件夹拖入应用窗口
2. **调整质量** - 使用底部滑块调整压缩质量(默认 80%)
3. **开始压缩** - 点击"开始压缩"按钮
4. **预览对比** - 点击眼睛图标查看压缩前后对比
5. **导出图片** - 点击"导出全部"保存压缩后的图片

## 🛠️ 技术栈

- **SwiftUI** - 现代化 UI 框架
- **Swift Concurrency** - 异步并发处理
- **AppKit** - macOS 原生图片处理

## 📝 开发计划

- [x] 基础 UI 框架
- [x] PNG/JPEG 压缩
- [x] 拖拽功能
- [x] 批量处理
- [x] 压缩预览对比
- [ ] WebP 格式支持
- [ ] GIF 优化
- [ ] 集成 pngquant 获得更好的 PNG 压缩
- [ ] 集成 mozjpeg 获得更好的 JPEG 压缩
- [ ] 深色模式优化
- [ ] 应用图标设计

## 🤝 贡献

欢迎提交 Issue 和 Pull Request!

## 📄 许可证

MIT License

## 🙏 致谢

本项目受 [PPDuck](https://ppduck.com) 启发,旨在提供一个免费开源的替代方案。

---

**开发者:** [Chengdu GUBT Industry Co., Ltd.](https://gubtcasting.com)  
**联系方式:** info@gubtcasting.com

Made with ❤️ for the community
