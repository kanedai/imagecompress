import Foundation

/// 字节大小格式化工具
struct ByteFormatter {
    /// 将字节数格式化为人类可读的字符串
    static func format(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        formatter.zeroPadsFractionDigits = true
        return formatter.string(fromByteCount: bytes)
    }
    
    /// 格式化压缩率
    static func formatRatio(_ ratio: Double) -> String {
        return String(format: "%.1f%%", ratio)
    }
}
