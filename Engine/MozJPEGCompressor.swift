import Foundation
import AppKit

/// MozJPEG 压缩器 - 使用专业的 MozJPEG 引擎
class MozJPEGCompressor: CompressionEngine {
    var supportedFormats: [String] = ["jpg", "jpeg"]
    
    private let toolManager = BinaryToolManager.shared
    private let settings = CompressionSettings.shared
    
    func compress(imageURL: URL, quality: Double) async throws -> Data {
        // 创建临时文件
        let tempDir = FileManager.default.temporaryDirectory
        let inputPath = tempDir.appendingPathComponent(UUID().uuidString + ".ppm")
        let outputPath = tempDir.appendingPathComponent(UUID().uuidString + ".jpg")
        
        defer {
            // 清理临时文件
            try? FileManager.default.removeItem(at: inputPath)
            try? FileManager.default.removeItem(at: outputPath)
        }
        
        // 检查工具是否可用
        guard toolManager.isAvailable(.cjpeg) else {
            // 回退到原生压缩
            return try await fallbackCompress(imageURL: imageURL, quality: quality)
        }
        
        // 读取原始图片并转换为 PPM 格式 (cjpeg 的输入格式)
        guard let image = NSImage(contentsOf: imageURL),
              let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            throw CompressionError.invalidImage
        }
        
        // 转换为 PPM 格式
        guard let ppmData = bitmapRep.representation(using: .bmp, properties: [:]) else {
            throw CompressionError.compressionFailed
        }
        
        // 使用 sips 转换为 PPM (因为 NSBitmapImageRep 不直接支持 PPM)
        // 先保存为 TIFF,然后用 sips 转换
        let tiffPath = tempDir.appendingPathComponent(UUID().uuidString + ".tiff")
        try tiffData.write(to: tiffPath)
        
        defer {
            try? FileManager.default.removeItem(at: tiffPath)
        }
        
        // 使用 sips 转换为 PPM
        let sipsProcess = Process()
        sipsProcess.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
        sipsProcess.arguments = ["-s", "format", "ppm", tiffPath.path, "--out", inputPath.path]
        sipsProcess.standardError = FileHandle.nullDevice
        sipsProcess.standardOutput = FileHandle.nullDevice
        
        try sipsProcess.run()
        sipsProcess.waitUntilExit()
        
        guard sipsProcess.terminationStatus == 0 else {
            return try await fallbackCompress(imageURL: imageURL, quality: quality)
        }
        
        // 构建 cjpeg 参数
        var arguments: [String] = [
            "-quality", "\(Int(quality * 100))",
            "-progressive",              // 渐进式编码
            "-optimize",                 // 优化 Huffman 表
            "-outfile", outputPath.path,
            inputPath.path
        ]
        
        // 如果不保留元数据,移除所有元数据
        // MozJPEG 默认不保留元数据,所以不需要额外参数
        
        // 运行 cjpeg
        do {
            try await toolManager.runWithFile(.cjpeg, inputPath: inputPath.path, outputPath: outputPath.path, arguments: arguments)
        } catch {
            // 如果 MozJPEG 失败,回退到原生压缩
            return try await fallbackCompress(imageURL: imageURL, quality: quality)
        }
        
        // 读取压缩后的文件
        guard FileManager.default.fileExists(atPath: outputPath.path) else {
            return try await fallbackCompress(imageURL: imageURL, quality: quality)
        }
        
        return try Data(contentsOf: outputPath)
    }
    
    /// 回退到原生压缩
    private func fallbackCompress(imageURL: URL, quality: Double) async throws -> Data {
        guard let image = NSImage(contentsOf: imageURL),
              let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            throw CompressionError.invalidImage
        }
        
        guard let compressedData = bitmapImage.representation(
            using: .jpeg,
            properties: [.compressionFactor: quality]
        ) else {
            throw CompressionError.compressionFailed
        }
        
        return compressedData
    }
}
