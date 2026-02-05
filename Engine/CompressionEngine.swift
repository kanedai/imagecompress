import Foundation
import AppKit

/// 压缩引擎协议
protocol CompressionEngine {
    /// 支持的文件格式
    var supportedFormats: [String] { get }
    
    /// 压缩图片
    /// - Parameters:
    ///   - imageURL: 图片文件路径
    ///   - quality: 压缩质量 (0-1)
    /// - Returns: 压缩后的图片数据
    func compress(imageURL: URL, quality: Double) async throws -> Data
}

/// 压缩错误
enum CompressionError: LocalizedError {
    case unsupportedFormat
    case compressionFailed
    case fileNotFound
    case invalidImage
    case toolNotFound(String)
    case toolFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "error.unsupported.format".localized
        case .compressionFailed:
            return "error.compression.failed".localized
        case .fileNotFound:
            return "error.file.not.found".localized
        case .invalidImage:
            return "error.invalid.image".localized
        case .toolNotFound(let tool):
            return "Compression tool not found: \(tool)"
        case .toolFailed(let message):
            return "Compression failed: \(message)"
        }
    }
}
