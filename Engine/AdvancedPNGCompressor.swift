import Foundation
import AppKit

/// PNG 压缩器 - 使用 pngquant + oxipng 组合
class AdvancedPNGCompressor: CompressionEngine {
    var supportedFormats: [String] = ["png"]
    
    private let toolManager = BinaryToolManager.shared
    private let settings = CompressionSettings.shared
    
    func compress(imageURL: URL, quality: Double) async throws -> Data {
        let tempDir = FileManager.default.temporaryDirectory
        let tempInput = tempDir.appendingPathComponent(UUID().uuidString + "_input.png")
        let tempQuantized = tempDir.appendingPathComponent(UUID().uuidString + "_quantized.png")
        let tempOutput = tempDir.appendingPathComponent(UUID().uuidString + "_output.png")
        
        defer {
            try? FileManager.default.removeItem(at: tempInput)
            try? FileManager.default.removeItem(at: tempQuantized)
            try? FileManager.default.removeItem(at: tempOutput)
        }
        
        // 复制原文件到临时目录
        try FileManager.default.copyItem(at: imageURL, to: tempInput)
        
        var currentFile = tempInput
        
        // 步骤 1: 使用 pngquant 进行有损压缩(减色)
        if toolManager.isAvailable(.pngquant) {
            do {
                // pngquant 参数:
                // --quality=min-max: 质量范围
                // --speed 1: 最慢但最好的压缩
                // --strip: 移除元数据
                // --force: 覆盖输出文件
                let minQuality = max(0, Int(quality * 100) - 20)
                let maxQuality = Int(quality * 100)
                
                var arguments = [
                    "--quality=\(minQuality)-\(maxQuality)",
                    "--speed", "1",
                    "--force",
                    "--output", tempQuantized.path,
                    tempInput.path
                ]
                
                // 如果不保留元数据,添加 --strip 参数
                if !settings.preserveMetadata {
                    arguments.insert("--strip", at: 0)
                }
                
                try await toolManager.runWithFile(.pngquant, inputPath: tempInput.path, outputPath: tempQuantized.path, arguments: arguments)
                
                if FileManager.default.fileExists(atPath: tempQuantized.path) {
                    currentFile = tempQuantized
                }
            } catch {
                // pngquant 失败,继续使用原文件
            }
        }
        
        // 步骤 2: 使用 oxipng 进行无损优化
        if toolManager.isAvailable(.oxipng) {
            do {
                // oxipng 参数:
                // -o 4: 优化级别 (0-6, 4 是较好的平衡)
                // --strip all: 移除所有元数据
                // --alpha: 优化 alpha 通道
                var arguments = [
                    "-o", "4",
                    "--alpha",
                    "--out", tempOutput.path,
                    currentFile.path
                ]
                
                // 如果不保留元数据,添加 --strip 参数
                if !settings.preserveMetadata {
                    arguments.insert(contentsOf: ["--strip", "all"], at: 0)
                }
                
                try await toolManager.runWithFile(.oxipng, inputPath: currentFile.path, outputPath: tempOutput.path, arguments: arguments)
                
                if FileManager.default.fileExists(atPath: tempOutput.path) {
                    currentFile = tempOutput
                }
            } catch {
                // oxipng 失败,使用当前文件
            }
        }
        
        // 如果没有任何工具可用,回退到原生压缩
        if currentFile == tempInput && !toolManager.isAvailable(.pngquant) && !toolManager.isAvailable(.oxipng) {
            return try await fallbackCompress(imageURL: imageURL, quality: quality)
        }
        
        // 读取最终结果
        return try Data(contentsOf: currentFile)
    }
    
    /// 回退到原生压缩
    private func fallbackCompress(imageURL: URL, quality: Double) async throws -> Data {
        guard let image = NSImage(contentsOf: imageURL),
              let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            throw CompressionError.invalidImage
        }
        
        guard let compressedData = bitmapImage.representation(
            using: .png,
            properties: [:]
        ) else {
            throw CompressionError.compressionFailed
        }
        
        return compressedData
    }
}
