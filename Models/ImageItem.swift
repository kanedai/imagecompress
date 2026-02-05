import Foundation

/// 图片项数据模型
struct ImageItem: Identifiable, Equatable {
    let id = UUID()
    let originalURL: URL
    var originalSize: Int64
    var compressedData: Data?
    var compressedSize: Int64?
    var status: CompressionStatus
    var progress: Double
    var error: String?
    
    /// 压缩率百分比
    var compressionRatio: Double? {
        guard let compressedSize = compressedSize else { return nil }
        let ratio = Double(originalSize - compressedSize) / Double(originalSize)
        return ratio * 100
    }
    
    /// 节省的字节数
    var savedBytes: Int64? {
        guard let compressedSize = compressedSize else { return nil }
        return originalSize - compressedSize
    }
    
    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// 压缩状态
enum CompressionStatus: Equatable {
    case pending       // 等待中
    case compressing   // 压缩中
    case completed     // 已完成
    case failed        // 失败
}
