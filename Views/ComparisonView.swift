import SwiftUI

/// 压缩前后对比视图
struct ComparisonView: View {
    let item: ImageItem
    @Environment(\.dismiss) var dismiss
    
    @State private var showOriginal = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(item.originalURL.lastPathComponent)
                    .font(.headline)
                
                Spacer()
                
                Button("comparison.close".localized) {
                    dismiss()
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            // 图片对比区域
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // 原图
                    imageView(
                        image: NSImage(contentsOf: item.originalURL),
                        title: "comparison.original".localized,
                        size: item.originalSize,
                        width: geometry.size.width / 2
                    )
                    
                    Divider()
                    
                    // 压缩后
                    imageView(
                        image: item.compressedData.flatMap { NSImage(data: $0) },
                        title: "comparison.compressed".localized,
                        size: item.compressedSize ?? 0,
                        width: geometry.size.width / 2
                    )
                }
            }
            
            // 底部信息栏
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let ratio = item.compressionRatio {
                        Text("comparison.ratio".localized(ByteFormatter.formatRatio(ratio)))
                            .font(.caption)
                    }
                    if let saved = item.savedBytes {
                        Text("comparison.saved".localized(ByteFormatter.format(saved)))
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                
                Spacer()
                
                Toggle("comparison.show.original".localized, isOn: $showOriginal)
                    .toggleStyle(.switch)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(width: 800, height: 600)
    }
    
    @ViewBuilder
    private func imageView(image: NSImage?, title: String, size: Int64, width: CGFloat) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
            }
            
            Text(ByteFormatter.format(size))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: width)
        .padding()
    }
}
