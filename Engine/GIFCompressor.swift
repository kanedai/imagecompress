import Foundation
import AppKit

/// GIF 压缩器 - 使用 gifsicle
class GIFCompressor: CompressionEngine {
    var supportedFormats: [String] = ["gif"]
    
    private let toolManager = BinaryToolManager.shared
    private let settings = CompressionSettings.shared
    
    func compress(imageURL: URL, quality: Double) async throws -> Data {
        let tempDir = FileManager.default.temporaryDirectory
        let tempOutput = tempDir.appendingPathComponent(UUID().uuidString + "_output.gif")
        
        defer {
            try? FileManager.default.removeItem(at: tempOutput)
        }
        
        // 检查 gifsicle 是否可用
        guard toolManager.isAvailable(.gifsicle) else {
            // 回退:直接返回原文件(GIF 没有好的原生压缩方案)
            return try Data(contentsOf: imageURL)
        }
        
        // gifsicle 参数:
        // -O3: 最高优化级别
        // --lossy=N: 有损压缩(N 越大压缩越多,建议 30-200)
        // --colors N: 限制颜色数量
        // -o: 输出文件
        
        // 根据质量参数计算 lossy 值(质量越低,lossy 越高)
        let lossyValue = Int((1.0 - quality) * 200) // 0-200
        
        // 根据质量参数计算颜色数量
        let colorCount = max(32, Int(quality * 256)) // 32-256
        
        var arguments = [
            "-O3",
            "--lossy=\(lossyValue)",
            "--colors", "\(colorCount)",
            "-o", tempOutput.path,
            imageURL.path
        ]
        
        do {
            try await toolManager.runWithFile(.gifsicle, inputPath: imageURL.path, outputPath: tempOutput.path, arguments: arguments)
            
            if FileManager.default.fileExists(atPath: tempOutput.path) {
                return try Data(contentsOf: tempOutput)
            }
        } catch {
            // gifsicle 失败,返回原文件
        }
        
        return try Data(contentsOf: imageURL)
    }
}
