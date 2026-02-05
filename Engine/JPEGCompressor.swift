import Foundation
import AppKit
import UniformTypeIdentifiers

/// JPEG 压缩器
class JPEGCompressor: CompressionEngine {
    var supportedFormats: [String] = ["jpg", "jpeg"]
    
    func compress(imageURL: URL, quality: Double) async throws -> Data {
        // 读取原始图片
        guard let image = NSImage(contentsOf: imageURL) else {
            throw CompressionError.invalidImage
        }
        
        // 获取图片的位图表示
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            throw CompressionError.compressionFailed
        }
        
        // 使用指定质量进行 JPEG 压缩
        guard let compressedData = bitmapImage.representation(
            using: .jpeg,
            properties: [.compressionFactor: quality]
        ) else {
            throw CompressionError.compressionFailed
        }
        
        return compressedData
    }
}
