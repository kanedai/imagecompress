import SwiftUI

/// 主视图
struct ContentView: View {
    @StateObject private var manager = CompressionManager()
    @State private var isTargeted = false
    @State private var showSettings = false  // 设置窗口状态
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部工具栏
            toolbar
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // 主内容区域
            if manager.items.isEmpty {
                // 空状态 - 显示拖拽区域
                DropZoneView(isTargeted: $isTargeted) { urls in
                    manager.addImages(urls: urls)
                }
            } else {
                // 图片列表
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(manager.items) { item in
                            ImageItemView(
                                item: item,
                                onRemove: {
                                    manager.removeItem(item)
                                }
                            )
                        }
                    }
                    .padding()
                }
                .background(
                    DropZoneView(isTargeted: $isTargeted) { urls in
                        manager.addImages(urls: urls)
                    }
                    .opacity(0.01) // 透明但仍可接收拖拽
                )
            }
            
            Divider()
            
            // 底部操作栏
            bottomBar
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(minWidth: 600, minHeight: 400)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // 顶部工具栏
    private var toolbar: some View {
        HStack {
            Text("main.title".localized)
                .font(.title2.bold())
            
            Spacer()
            
            // 统计信息
            if !manager.items.isEmpty {
                HStack(spacing: 16) {
                    Label("\(manager.items.count)", systemImage: "photo.stack")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if manager.totalSaved > 0 {
                        Label(
                            "main.saved".localized(ByteFormatter.format(manager.totalSaved)),
                            systemImage: "arrow.down.circle.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(.green)
                    }
                }
            }
            
            // 设置按钮
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .help("toolbar.settings".localized)
        }
    }
    
    // 底部操作栏
    private var bottomBar: some View {
        VStack(spacing: 8) {
            HStack {
                // 压缩质量滑块
                HStack {
                    Text("bottombar.quality".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Slider(
                        value: Binding(
                            get: { CompressionSettings.shared.quality },
                            set: { CompressionSettings.shared.quality = $0 }
                        ),
                        in: 0.1...1.0,
                        step: 0.05
                    )
                    .frame(width: 150)
                    
                    Text("\(Int(CompressionSettings.shared.quality * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40)
                }
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 12) {
                    if !manager.items.isEmpty {
                        Button("bottombar.clear".localized) {
                            manager.clearAll()
                        }
                        .disabled(manager.isCompressing)
                        
                        if !CompressionSettings.shared.overwriteOriginal {
                            Button("bottombar.export".localized) {
                                exportAll()
                            }
                            .disabled(manager.items.filter { $0.status == .completed }.isEmpty)
                        }
                        
                        Button("bottombar.compress".localized) {
                            Task {
                                await manager.compressAll()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(manager.isCompressing || manager.items.filter { $0.status == .pending }.isEmpty)
                    }
                }
            }
            
            // 公司版权信息
            HStack(spacing: 4) {
                Text("©")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                Link("bottombar.company.name".localized, destination: URL(string: "https://gubtcasting.com")!)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                Text("•")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                
                Link("info@gubtcasting.com", destination: URL(string: "mailto:info@gubtcasting.com")!)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    // 导出所有压缩后的图片
    private func exportAll() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "filepicker.select.directory".localized
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                Task {
                    do {
                        try await manager.exportAll(to: url)
                        
                        // 显示成功提示
                        let alert = NSAlert()
                        alert.messageText = "alert.export.success.title".localized
                        alert.informativeText = "alert.export.success.message".localized(manager.items.filter { $0.status == .completed }.count)
                        alert.alertStyle = .informational
                        alert.runModal()
                    } catch {
                        // 显示错误提示
                        let alert = NSAlert()
                        alert.messageText = "alert.export.failed.title".localized
                        alert.informativeText = error.localizedDescription
                        alert.alertStyle = .critical
                        alert.runModal()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
