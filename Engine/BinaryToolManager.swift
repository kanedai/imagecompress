import Foundation

/// 二进制工具管理器
/// 管理压缩工具的路径和调用
class BinaryToolManager {
    static let shared = BinaryToolManager()
    
    /// 工具类型
    enum Tool: String {
        case cjpeg = "cjpeg"           // MozJPEG
        case djpeg = "djpeg"           // MozJPEG 解码
        case pngquant = "pngquant"     // PNG 有损压缩
        case oxipng = "oxipng"         // PNG 无损优化
        case gifsicle = "gifsicle"     // GIF 优化
    }
    
    /// Homebrew 安装路径
    private let homebrewPaths: [String] = [
        "/opt/homebrew/bin",           // Apple Silicon
        "/usr/local/bin",              // Intel
        "/opt/homebrew/opt/mozjpeg/bin" // MozJPEG 特殊路径
    ]
    
    /// 获取工具路径
    func path(for tool: Tool) -> String? {
        // 首先检查应用 Bundle 中的工具
        if let bundlePath = bundlePath(for: tool) {
            return bundlePath
        }
        
        // 然后检查 Homebrew 安装
        for basePath in homebrewPaths {
            let toolPath = "\(basePath)/\(tool.rawValue)"
            if FileManager.default.fileExists(atPath: toolPath) {
                return toolPath
            }
        }
        
        // 最后尝试 which 命令
        return whichPath(for: tool)
    }
    
    /// 检查工具是否可用
    func isAvailable(_ tool: Tool) -> Bool {
        return path(for: tool) != nil
    }
    
    /// 获取 Bundle 中的工具路径
    private func bundlePath(for tool: Tool) -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let toolPath = "\(resourcePath)/Binaries/\(tool.rawValue)"
        return FileManager.default.fileExists(atPath: toolPath) ? toolPath : nil
    }
    
    /// 使用 which 命令查找工具
    private func whichPath(for tool: Tool) -> String? {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [tool.rawValue]
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let path = output, !path.isEmpty, FileManager.default.fileExists(atPath: path) {
                return path
            }
        } catch {
            // 忽略错误
        }
        
        return nil
    }
    
    /// 运行工具
    func run(_ tool: Tool, arguments: [String], inputData: Data? = nil) async throws -> Data {
        guard let toolPath = path(for: tool) else {
            throw CompressionError.toolNotFound(tool.rawValue)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                let outputPipe = Pipe()
                let errorPipe = Pipe()
                let inputPipe = Pipe()
                
                process.executableURL = URL(fileURLWithPath: toolPath)
                process.arguments = arguments
                process.standardOutput = outputPipe
                process.standardError = errorPipe
                
                if inputData != nil {
                    process.standardInput = inputPipe
                }
                
                do {
                    try process.run()
                    
                    // 写入输入数据
                    if let inputData = inputData {
                        inputPipe.fileHandleForWriting.write(inputData)
                        inputPipe.fileHandleForWriting.closeFile()
                    }
                    
                    process.waitUntilExit()
                    
                    if process.terminationStatus == 0 {
                        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                        continuation.resume(returning: outputData)
                    } else {
                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                        continuation.resume(throwing: CompressionError.toolFailed(errorMessage))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// 运行工具处理文件
    func runWithFile(_ tool: Tool, inputPath: String, outputPath: String, arguments: [String]) async throws {
        guard let toolPath = path(for: tool) else {
            throw CompressionError.toolNotFound(tool.rawValue)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                let errorPipe = Pipe()
                
                process.executableURL = URL(fileURLWithPath: toolPath)
                process.arguments = arguments
                process.standardError = errorPipe
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    if process.terminationStatus == 0 {
                        continuation.resume(returning: ())
                    } else {
                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                        continuation.resume(throwing: CompressionError.toolFailed(errorMessage))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// 获取所有工具的可用状态
    func getToolsStatus() -> [Tool: Bool] {
        var status: [Tool: Bool] = [:]
        for tool in [Tool.cjpeg, .djpeg, .pngquant, .oxipng, .gifsicle] {
            status[tool] = isAvailable(tool)
        }
        return status
    }
}
