import SwiftUI

/// 单个图片项视图
struct ImageItemView: View {
    let item: ImageItem
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 图片缩略图
            if let image = NSImage(contentsOf: item.originalURL) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .frame(width: 50, height: 50)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // 文件信息
            VStack(alignment: .leading, spacing: 4) {
                Text(item.originalURL.lastPathComponent)
                    .font(.system(.body, design: .rounded))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(ByteFormatter.format(item.originalSize))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let compressedSize = item.compressedSize {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text(ByteFormatter.format(compressedSize))
                            .font(.caption)
                            .foregroundStyle(.green)
                        
                        if let ratio = item.compressionRatio {
                            Text("(\(ByteFormatter.formatRatio(ratio)) ↓)")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            
            Spacer()
            
            // 状态指示器
            statusView
            
            // 操作按钮
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("item.remove".localized)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch item.status {
        case .pending:
            Image(systemName: "clock")
                .foregroundStyle(.secondary)
                .help("item.pending".localized)
            
        case .compressing:
            ProgressView(value: item.progress)
                .progressViewStyle(.circular)
                .scaleEffect(0.7)
                .help("item.compressing".localized)
            
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .help("item.completed".localized)
            
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .help(item.error ?? "item.failed".localized)
        }
    }
}
