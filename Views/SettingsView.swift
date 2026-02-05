import SwiftUI

/// 设置视图
struct SettingsView: View {
    @ObservedObject var settings = CompressionSettings.shared
    
    var body: some View {
        Form {
            Section {
                Toggle("settings.preserve.metadata".localized, isOn: $settings.preserveMetadata)
                Toggle("settings.overwrite.original".localized, isOn: $settings.overwriteOriginal)
                
                Picker("settings.output.format".localized, selection: $settings.outputFormat) {
                    ForEach(OutputFormat.allCases) { format in
                        Text(format.localizedName).tag(format)
                    }
                }
            } header: {
                Text("settings.output".localized)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    // 公司 Logo
                    if let logo = NSImage(named: "CompanyLogo") {
                        Image(nsImage: logo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                    }
                    
                    Text("ImageCompress")
                        .font(.headline)
                    
                    Text("settings.description".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("settings.version".localized("1.0.0"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("settings.company.name".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Link("https://gubtcasting.com", destination: URL(string: "https://gubtcasting.com")!)
                        .font(.caption)
                    
                    Link("info@gubtcasting.com", destination: URL(string: "mailto:info@gubtcasting.com")!)
                        .font(.caption)
                }
            } header: {
                Text("settings.about".localized)
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 400)
    }
}
