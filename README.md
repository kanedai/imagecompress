# ImageCompress

A professional macOS batch image compression tool built with native SwiftUI, integrating multiple advanced compression algorithms.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## ✨ Features

### 🖼️ Multi-Format Support
- **JPEG** - High-quality compression using the MozJPEG encoder
- **PNG** - Dual-engine optimization with pngquant (lossy) + oxipng (lossless)
- **GIF** - Animated image optimization using gifsicle
- **WebP** - Support for WebP format output conversion

### ⚡ Core Capabilities
- Drag-and-drop image addition with batch processing support
- Real-time preview of compression results and space savings
- Adjustable compression quality (10%-100%)
- Option to overwrite original files or export to a specified directory
- EXIF metadata retention options

### 🌍 Internationalization
- 简体中文 (Simplified Chinese)
- English

## 🛠️ Technical Architecture

```
ImageCompress/
├── ImageCompressApp.swift     # Application entry point
├── Engine/                    # Compression engine
│   ├── CompressionEngine.swift      # Compression protocol definition
│   ├── CompressionManager.swift     # Compression task manager
│   ├── MozJPEGCompressor.swift      # MozJPEG compression implementation
│   ├── AdvancedPNGCompressor.swift  # Advanced PNG compression
│   ├── GIFCompressor.swift          # GIF optimization
│   ├── JPEGCompressor.swift         # Standard JPEG compression
│   ├── PNGCompressor.swift          # Standard PNG compression
│   └── BinaryToolManager.swift      # Binary tool manager
├── Models/                    # Data models
│   ├── CompressionSettings.swift    # Compression settings
│   └── ImageItem.swift              # Image item model
├── Views/                     # View components
│   ├── ContentView.swift            # Main view
│   ├── SettingsView.swift           # Settings view
│   ├── ImageItemView.swift          # Image item view
│   ├── ComparisonView.swift         # Comparison view
│   └── DropZoneView.swift           # Drop zone area
└── Utils/                     # Utilities
    ├── ByteFormatter.swift          # File size formatter
    └── Localization.swift           # Localization support
```

## 📦 Compression Tool Dependencies

This application integrates the following open-source compression tools for optimal results:

| Tool | Purpose | Official Website |
|------|---------|------------------|
| [MozJPEG](https://github.com/mozilla/mozjpeg) | High-quality JPEG compression | mozilla/mozjpeg |
| [pngquant](https://pngquant.org/) | Lossy PNG compression | pngquant.org |
| [oxipng](https://github.com/shssoichiro/oxipng) | Lossless PNG optimization | shssoichiro/oxipng |
| [gifsicle](https://www.lcdf.org/gifsicle/) | GIF animation optimization | lcdf.org/gifsicle |

### Install Dependencies (via Homebrew)

```bash
brew install mozjpeg pngquant oxipng gifsicle
```

## 🚀 Quick Start

### System Requirements
- macOS 13.0 or later
- Xcode 15.0 or later

### Build the Project

```bash
# Clone the repository
git clone https://github.com/kanedai/imagecompress.git
cd imagecompress

# Open the project with Xcode
open ImageCompress.xcodeproj

# Or build using command line
xcodebuild -project ImageCompress.xcodeproj -scheme ImageCompress -configuration Release
```

## 📖 Usage Guide

1. **Add Images** - Drag and drop images into the application window, or add via file picker
2. **Adjust Quality** - Use the bottom slider to set compression quality (10%-100%)
3. **Configure Options** - Click the settings button to configure output format, metadata retention, etc.
4. **Start Compression** - Click the "Compress" button to begin batch processing
5. **View Results** - Real-time display of compression progress and space savings

## 🔧 Settings Options

| Option | Description | Default |
|--------|-------------|---------|
| Compression Quality | Image compression quality percentage | 80% |
| Output Format | Original/PNG/JPEG/WebP | Original |
| Overwrite Original | Whether to overwrite source files | Enabled |
| Preserve Metadata | Retain EXIF and other metadata | Disabled |

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

## 🏢 About

Developed by **[GUBT Casting](https://gubtcasting.com)** — High-Performance Wear Parts for Crushers

GUBT is a specialized manufacturer of aftermarket wear parts for the mining and quarrying industries. Based in China, we produce over 15,000 spare parts compatible with major crusher brands like Metso, Sandvik, and Symons. Our inventory includes manganese liners, mantle and concave sets, and various mechanical components designed to match or exceed OEM specifications.

We manage the entire production process in-house—from initial pattern design and casting to final machining and quality control. This vertical integration allows us to maintain tight tolerances and offer shorter lead times than many international distributors. Whether you are running a large-scale mining operation or a local aggregate plant, GUBT provides the durable parts needed to minimize downtime and lower your cost per ton.

📧 Contact us: [info@gubtcasting.com](mailto:info@gubtcasting.com)

🌐 Website: [gubtcasting.com](https://gubtcasting.com)

---

⭐ If you find this project helpful, please give it a Star!
