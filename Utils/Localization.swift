import Foundation

/// 本地化辅助工具
struct L10n {
    /// 获取本地化字符串
    static func string(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        return String(format: format, arguments: args)
    }
}

/// 字符串扩展,简化本地化调用
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: args)
    }
}
