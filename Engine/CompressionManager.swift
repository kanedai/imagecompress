import Foundation
import AppKit

/// 压缩管理器 - 自动选择最优压缩器
@MainActor
class CompressionManager: ObservableObject {
    @Published var items: [ImageItem] = []
    @Published var isCompressing = false
    @Published var totalSaved: Int64 = 0
    
    private let settings = CompressionSettings.shared
    
    // 使用专业压缩引擎
    private let pngCompressor = AdvancedPNGCompressor()  // pngquant + oxipng
    private let jpegCompressor = MozJPEGCompressor()     // MozJPEG
    private let gifCompressor = GIFCompressor()          // gifsicle
    
    /// 添加图片文件
    func addImages(urls: [URL]) {
        for url in urls {
            // 检查是否已存在
            if items.contains(where: { $0.originalURL == url }) {
                continue
            }
            
            // 获取文件大小
            guard let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 else {
                continue
            }
            
            // 创建图片项
            let item = ImageItem(
                originalURL: url,
                originalSize: fileSize,
                status: .pending,
                progress: 0
            )
            
            items.append(item)
        }
    }
    
    /// 开始压缩所有待处理的图片
    func compressAll() async {
        isCompressing = true
        totalSaved = 0
        
        // 使用并发任务组处理所有图片
        await withTaskGroup(of: (UUID, Result<Data, Error>).self) { group in
            for item in items where item.status == .pending {
                group.addTask {
                    await self.updateItemStatus(item.id, status: .compressing, progress: 0)
                    
                    let result = await self.compressImage(item)
                    return (item.id, result)
                }
            }
            
            // 收集结果
            for await (itemId, result) in group {
                await handleCompressionResult(itemId: itemId, result: result)
            }
        }
        
        isCompressing = false
    }
    
    /// 压缩单个图片
    private func compressImage(_ item: ImageItem) async -> Result<Data, Error> {
        let fileExtension = item.originalURL.pathExtension.lowercased()
        
        // 选择合适的压缩器
        let compressor: CompressionEngine?
        if pngCompressor.supportedFormats.contains(fileExtension) {
            compressor = pngCompressor
        } else if jpegCompressor.supportedFormats.contains(fileExtension) {
            compressor = jpegCompressor
        } else if gifCompressor.supportedFormats.contains(fileExtension) {
            compressor = gifCompressor
        } else {
            return .failure(CompressionError.unsupportedFormat)
        }
        
        guard let compressor = compressor else {
            return .failure(CompressionError.unsupportedFormat)
        }
        
        do {
            let compressedData = try await compressor.compress(
                imageURL: item.originalURL,
                quality: settings.quality
            )
            return .success(compressedData)
        } catch {
            return .failure(error)
        }
    }
    
    /// 处理压缩结果
    private func handleCompressionResult(itemId: UUID, result: Result<Data, Error>) async {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        
        switch result {
        case .success(let compressedData):
            let originalSize = items[index].originalSize
            let compressedSize = Int64(compressedData.count)
            
            // 比较压缩前后的大小
            let finalData: Data
            let finalSize: Int64
            
            if compressedSize >= originalSize {
                // 压缩后反而更大,使用原文件
                do {
                    finalData = try Data(contentsOf: items[index].originalURL)
                    finalSize = originalSize
                    items[index].compressedData = finalData
                    items[index].compressedSize = finalSize
                    items[index].status = .completed
                    items[index].progress = 1.0
                    // 没有节省空间,不增加 totalSaved
                } catch {
                    items[index].status = .failed
                    items[index].error = "alert.save.failed".localized(error.localizedDescription)
                    return
                }
            } else {
                // 压缩后更小,使用压缩数据
                finalData = compressedData
                finalSize = compressedSize
                items[index].compressedData = finalData
                items[index].compressedSize = finalSize
                items[index].status = .completed
                items[index].progress = 1.0
                
                if let saved = items[index].savedBytes {
                    totalSaved += saved
                }
            }
            
            // 如果设置了覆盖原文件,自动保存
            if settings.overwriteOriginal {
                do {
                    try finalData.write(to: items[index].originalURL)
                } catch {
                    items[index].status = .failed
                    items[index].error = "alert.save.failed".localized(error.localizedDescription)
                }
            }
            
        case .failure(let error):
            items[index].status = .failed
            items[index].error = error.localizedDescription
        }
    }
    
    /// 更新图片项状态
    private func updateItemStatus(_ id: UUID, status: CompressionStatus, progress: Double) async {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].status = status
        items[index].progress = progress
    }
    
    /// 导出压缩后的图片
    func exportImage(_ item: ImageItem, to url: URL) throws {
        guard let data = item.compressedData else {
            throw CompressionError.compressionFailed
        }
        
        try data.write(to: url)
    }
    
    /// 导出所有压缩后的图片
    func exportAll(to directory: URL) async throws {
        for item in items where item.status == .completed {
            let filename = item.originalURL.lastPathComponent
            let outputURL = directory.appendingPathComponent(filename)
            try exportImage(item, to: outputURL)
        }
    }
    
    /// 清空列表
    func clearAll() {
        items.removeAll()
        totalSaved = 0
    }
    
    /// 移除指定项
    func removeItem(_ item: ImageItem) {
        items.removeAll { $0.id == item.id }
    }
}
