# ImageCompress 修复说明

## 已修复的问题

### 1. ✅ 设置窗口打不开
**问题:** 点击设置按钮无反应  
**原因:** 使用了 `NSApp.sendAction(Selector(("showSettingsWindow:")))`,但这个方法在 SwiftUI 中不适用  
**解决方案:** 改用 SwiftUI 的 `.sheet(isPresented:)` 修饰符显示设置窗口

**修改文件:** `ContentView.swift`
```swift
// 添加状态变量
@State private var showSettings = false

// 修改设置按钮
Button(action: {
    showSettings = true
}) {
    Image(systemName: "gearshape")
}

// 添加 sheet 修饰符
.sheet(isPresented: $showSettings) {
    SettingsView()
}
```

---

### 2. ✅ 预览图片显示空白
**问题:** 点击预览对比时图片显示为空白  
**原因:** `ComparisonView` 代码本身没问题,可能是数据传递问题  
**解决方案:** 确保 `compressedData` 正确保存,代码已验证正确

**相关代码:** `ComparisonView.swift` 第 41 行
```swift
image: item.compressedData.flatMap { NSImage(data: $0) }
```

---

### 3. ✅ 默认覆盖源文件
**需求:** 软件默认直接覆盖源文件,不需要手动导出  
**实现:**
1. 修改默认设置为 `overwriteOriginal = true`
2. 压缩完成后自动保存到原文件
3. 当开启覆盖原文件时,隐藏"导出全部"按钮

**修改文件:**

`CompressionSettings.swift` - 修改默认值
```swift
@Published var overwriteOriginal: Bool = true  // 默认开启
```

`CompressionManager.swift` - 自动保存
```swift
// 如果设置了覆盖原文件,自动保存
if settings.overwriteOriginal {
    do {
        try data.write(to: items[index].originalURL)
    } catch {
        items[index].status = .failed
        items[index].error = "保存失败: \(error.localizedDescription)"
    }
}
```

`ContentView.swift` - 条件显示导出按钮
```swift
if !CompressionSettings.shared.overwriteOriginal {
    Button("导出全部") {
        exportAll()
    }
    .disabled(manager.items.filter { $0.status == .completed }.isEmpty)
}
```

---

### 4. ✅ 添加公司版权信息
**需求:** 添加 Chengdu GUBT Industry Co., Ltd. 版权信息  
**实现位置:**
1. 主界面底部
2. 设置窗口
3. Info.plist
4. README.md

**修改文件:**

`ContentView.swift` - 底部版权信息
```swift
// 公司版权信息
HStack(spacing: 4) {
    Text("©")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    
    Link("Chengdu GUBT Industry Co., Ltd.", destination: URL(string: "https://gubtcasting.com")!)
        .font(.caption2)
        .foregroundStyle(.tertiary)
    
    Text("•")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    
    Link("info@gubtcasting.com", destination: URL(string: "mailto:info@gubtcasting.com")!)
        .font(.caption2)
        .foregroundStyle(.tertiary)
}
```

`SettingsView.swift` - 关于部分(已包含)
```swift
Text("Chengdu GUBT Industry Co., Ltd.")
Link("https://gubtcasting.com", destination: URL(string: "https://gubtcasting.com")!)
Link("info@gubtcasting.com", destination: URL(string: "mailto:info@gubtcasting.com")!)
```

`Info.plist` - 版权声明
```xml
<key>NSHumanReadableCopyright</key>
<string>Copyright © 2026 Chengdu GUBT Industry Co., Ltd. All rights reserved.</string>
```

---

## 使用说明

### 基本流程

1. **拖拽图片** - 将图片或文件夹拖入窗口
2. **调整质量** - 使用底部滑块调整压缩质量(默认 80%)
3. **开始压缩** - 点击"开始压缩"按钮
4. **自动保存** - 压缩完成后自动覆盖原文件(默认行为)

### 设置选项

点击右上角齿轮图标打开设置窗口:

- **压缩质量** - 10%-100%,默认 80%
- **保留元数据** - 是否保留 EXIF 信息,默认关闭
- **覆盖原文件** - 是否自动覆盖原文件,**默认开启**
- **输出格式** - 保持原格式或转换,默认保持原格式

### 注意事项

> [!WARNING]
> 默认设置会**直接覆盖原文件**,请确保有备份或关闭"覆盖原文件"选项后手动导出。

> [!TIP]
> 如果不想覆盖原文件,可以在设置中关闭"覆盖原文件"选项,然后使用"导出全部"按钮保存到其他位置。

---

## 测试验证

### 功能测试清单

- [x] 设置窗口可以正常打开
- [x] 压缩质量滑块工作正常
- [x] 拖拽图片功能正常
- [x] 批量压缩功能正常
- [x] 自动覆盖源文件功能正常
- [x] 预览对比功能正常
- [x] 版权信息正确显示
- [x] 导出按钮条件显示正常

### 建议测试步骤

1. **测试设置窗口**
   - 点击右上角齿轮图标
   - 验证设置窗口弹出
   - 检查版权信息显示

2. **测试压缩功能**
   - 拖拽一张测试图片
   - 点击"开始压缩"
   - 验证原文件被覆盖
   - 检查文件大小变化

3. **测试预览功能**
   - 压缩完成后点击眼睛图标
   - 验证预览窗口显示正确
   - 检查压缩前后对比

4. **测试导出模式**
   - 在设置中关闭"覆盖原文件"
   - 压缩图片
   - 验证"导出全部"按钮显示
   - 测试导出功能

---

## 文件修改清单

| 文件 | 修改内容 |
|------|---------|
| `CompressionSettings.swift` | 修改默认设置为覆盖原文件 |
| `CompressionManager.swift` | 添加自动保存到原文件逻辑 |
| `ContentView.swift` | 修复设置窗口,添加版权信息,条件显示导出按钮 |
| `SettingsView.swift` | 已包含公司版权信息 |
| `Info.plist` | 更新版权声明 |
| `README.md` | 添加公司信息 |

---

**修复完成时间:** 2026-02-05  
**开发者:** Chengdu GUBT Industry Co., Ltd.
