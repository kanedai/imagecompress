# ImageCompress

一款专业的 macOS 图片批量压缩工具，采用 SwiftUI 原生开发，集成多种先进压缩算法。

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ 功能特性

### 🖼️ 多格式支持
- **JPEG** - 使用 MozJPEG 编码器实现高质量压缩
- **PNG** - 集成 pngquant (有损) + oxipng (无损) 双引擎优化
- **GIF** - 使用 gifsicle 进行动图优化
- **WebP** - 支持转换输出为 WebP 格式

### ⚡ 核心功能
- 拖拽添加图片，支持批量处理
- 实时预览压缩效果和节省空间
- 可调节压缩质量 (10%-100%)
- 支持覆盖原文件或导出到指定目录
- EXIF 元数据保留选项

### 🌍 国际化
- 简体中文
- English

## 🛠️ 技术架构

```
ImageCompress/
├── ImageCompressApp.swift     # 应用入口
├── Engine/                    # 压缩引擎
│   ├── CompressionEngine.swift      # 压缩协议定义
│   ├── CompressionManager.swift     # 压缩任务管理
│   ├── MozJPEGCompressor.swift      # MozJPEG 压缩实现
│   ├── AdvancedPNGCompressor.swift  # PNG 高级压缩
│   ├── GIFCompressor.swift          # GIF 优化
│   ├── JPEGCompressor.swift         # 标准 JPEG 压缩
│   ├── PNGCompressor.swift          # 标准 PNG 压缩
│   └── BinaryToolManager.swift      # 二进制工具管理
├── Models/                    # 数据模型
│   ├── CompressionSettings.swift    # 压缩设置
│   └── ImageItem.swift              # 图片项模型
├── Views/                     # 视图组件
│   ├── ContentView.swift            # 主视图
│   ├── SettingsView.swift           # 设置视图
│   ├── ImageItemView.swift          # 图片项视图
│   ├── ComparisonView.swift         # 对比视图
│   └── DropZoneView.swift           # 拖拽区域
└── Utils/                     # 工具类
    ├── ByteFormatter.swift          # 文件大小格式化
    └── Localization.swift           # 本地化支持
```

## 📦 压缩工具依赖

应用集成以下开源压缩工具以实现最佳压缩效果：

| 工具 | 用途 | 官方网站 |
|------|------|----------|
| [MozJPEG](https://github.com/mozilla/mozjpeg) | JPEG 高质量压缩 | mozilla/mozjpeg |
| [pngquant](https://pngquant.org/) | PNG 有损压缩 | pngquant.org |
| [oxipng](https://github.com/shssoichiro/oxipng) | PNG 无损优化 | shssoichiro/oxipng |
| [gifsicle](https://www.lcdf.org/gifsicle/) | GIF 动图优化 | lcdf.org/gifsicle |

### 安装依赖 (通过 Homebrew)

```bash
brew install mozjpeg pngquant oxipng gifsicle
```

## 🚀 快速开始

### 系统要求
- macOS 13.0 或更高版本
- Xcode 15.0 或更高版本

### 构建项目

```bash
# 克隆仓库
git clone https://github.com/kanedai/imagecompress.git
cd imagecompress

# 使用 Xcode 打开项目
open ImageCompress.xcodeproj

# 或使用命令行构建
xcodebuild -project ImageCompress.xcodeproj -scheme ImageCompress -configuration Release
```

## 📖 使用说明

1. **添加图片** - 拖拽图片到应用窗口，或通过文件选择器添加
2. **调整质量** - 使用底部滑块调节压缩质量 (10%-100%)
3. **配置选项** - 点击设置按钮配置输出格式、元数据保留等选项
4. **开始压缩** - 点击"压缩"按钮开始批量处理
5. **查看结果** - 实时显示压缩进度和节省空间

## 🔧 设置选项

| 选项 | 说明 | 默认值 |
|------|------|--------|
| 压缩质量 | 图片压缩质量百分比 | 80% |
| 输出格式 | 原格式/PNG/JPEG/WebP | 原格式 |
| 覆盖原文件 | 是否覆盖源文件 | 开启 |
| 保留元数据 | 保留 EXIF 等元数据 | 关闭 |

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🏢 关于

由 [成都古柏特实业有限公司 (GUBT)](https://gubtcasting.com) 开发

📧 联系我们: [info@gubtcasting.com](mailto:info@gubtcasting.com)

---

⭐ 如果这个项目对你有帮助，欢迎 Star！
