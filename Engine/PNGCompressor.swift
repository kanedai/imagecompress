import Foundation
import AppKit
import UniformTypeIdentifiers

/// PNG 压缩器
class PNGCompressor: CompressionEngine {
    var supportedFormats: [String] = ["png"]
    
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
        
        // 使用 NSBitmapImageRep 的 PNG 压缩
        // 注意: macOS 原生 PNG 压缩不支持质量参数,这里我们先使用默认压缩
        // 后续可以集成 pngquant 或 oxipng 获得更好的压缩效果
        guard let compressedData = bitmapImage.representation(
            using: .png,
            properties: [:]
        ) else {
            throw CompressionError.compressionFailed
        }
        
        return compressedData
    }
}
