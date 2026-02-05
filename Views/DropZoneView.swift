import SwiftUI
import UniformTypeIdentifiers

/// 拖拽区域视图
struct DropZoneView: View {
    @Binding var isTargeted: Bool
    let onDrop: ([URL]) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("dropzone.title".localized)
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Text("dropzone.formats".localized)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
                )
        )
        .padding()
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        var urls: [URL] = []
        
        let group = DispatchGroup()
        
        for provider in providers {
            group.enter()
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                defer { group.leave() }
                
                guard let url = url else { return }
                
                // 检查是否是目录
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // 递归获取目录中的所有图片文件
                        if let imageURLs = getImageURLs(from: url) {
                            urls.append(contentsOf: imageURLs)
                        }
                    } else {
                        // 单个文件
                        if isImageFile(url) {
                            urls.append(url)
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            if !urls.isEmpty {
                onDrop(urls)
            }
        }
    }
    
    /// 检查是否是图片文件
    private func isImageFile(_ url: URL) -> Bool {
        let imageExtensions = ["png", "jpg", "jpeg", "gif", "webp", "heic", "heif"]
        return imageExtensions.contains(url.pathExtension.lowercased())
    }
    
    /// 递归获取目录中的所有图片文件
    private func getImageURLs(from directory: URL) -> [URL]? {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }
        
        var imageURLs: [URL] = []
        
        for case let fileURL as URL in enumerator {
            if isImageFile(fileURL) {
                imageURLs.append(fileURL)
            }
        }
        
        return imageURLs
    }
}
