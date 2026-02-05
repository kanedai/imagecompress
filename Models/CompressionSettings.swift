import Foundation

/// 压缩设置
class CompressionSettings: ObservableObject {
    @Published var quality: Double = 0.8  // 压缩质量 0-1
    @Published var preserveMetadata: Bool = false  // 保留元数据
    @Published var overwriteOriginal: Bool = true  // 覆盖原文件(默认开启)
    @Published var outputFormat: OutputFormat = .original  // 输出格式
    
    static let shared = CompressionSettings()
    
    private init() {}
}

/// 输出格式
enum OutputFormat: String, CaseIterable, Identifiable {
    case original = "format.original"
    case png = "format.png"
    case jpeg = "format.jpeg"
    case webp = "format.webp"
    
    var id: String { rawValue }
    
    var localizedName: String {
        rawValue.localized
    }
    
    var fileExtension: String {
        switch self {
        case .original: return ""
        case .png: return "png"
        case .jpeg: return "jpg"
        case .webp: return "webp"
        }
    }
}
