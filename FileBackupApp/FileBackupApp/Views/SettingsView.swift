import SwiftUI

struct SettingsView: View {
    @AppStorage("exportFormat") private var exportFormat = "ZIP"

    var body: some View {
        NavigationStack {
            List {
                Section("上传与备份") {
                    LabeledRow(icon: "square.and.arrow.up", color: .orange, title: "上传方式", value: "手动导入")
                    LabeledRow(icon: "folder.fill", color: .blue, title: "备份目录", value: "Documents/Backup")
                    Picker("导出格式", selection: $exportFormat) {
                        Text("ZIP").tag("ZIP")
                        Text("原文件").tag("RAW")
                    }
                }

                Section("数据") {
                    LabeledRow(icon: "doc.richtext.fill", color: .orange, title: "HTML 文件", value: "管理网页与文档")
                    LabeledRow(icon: "f.cursive", color: .purple, title: "TTF 字体", value: "管理字体文件")
                }

                Section("关于") {
                    LabeledRow(icon: "info.circle.fill", color: .gray, title: "版本", value: "v1.0")
                    Button(role: .destructive) {
                        // 清除备份逻辑：BackupStore 中删除 Backup 目录
                    } label: {
                        Label("清除备份", systemImage: "trash.fill")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

struct LabeledRow: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon).foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text(title)
            Spacer()
            Text(value).foregroundStyle(.secondary).font(.subheadline)
        }
    }
}
