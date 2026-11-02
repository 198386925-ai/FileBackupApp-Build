import SwiftUI

struct BrowserView: View {
    @EnvironmentObject private var store: BackupStore
    @State private var filter: BackupItemKind?
    @State private var showImporter = false

    private var displayed: [BackupItem] {
        guard let filter else { return store.items }
        return store.items.filter { $0.kind == filter }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                    uploadButton
                    statsGrid
                    filterPicker
                    sectionTitle
                    if displayed.isEmpty {
                        emptyState
                    } else {
                        fileList
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("文件备份")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await store.backupAll() }
                    } label: {
                        Image(systemName: "arrow.up.doc.fill")
                    }
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: BackupFileManager.supportedTypes,
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    store.importFiles(from: urls)
                case .failure(let error):
                    print("导入失败: \(error.localizedDescription)")
                }
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("我的文件").font(.subheadline).foregroundStyle(.secondary)
                Text("文件备份").font(.largeTitle.bold())
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    /// 手动上传入口：调起系统文件选择器
    private var uploadButton: some View {
        Button {
            showImporter = true
        } label: {
            Label("上传 HTML / TTF 文件", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray.and.arrow.up").font(.system(size: 42)).foregroundStyle(.secondary)
            Text("还没有文件").font(.headline)
            Text("点击上方「上传」从系统文件 App 导入 HTML 或 TTF 文件")
                .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(icon: "doc.richtext.fill", color: .orange, num: "\(store.htmlItems.count)", label: "HTML 文件")
            StatCard(icon: "f.cursive", color: .purple, num: "\(store.ttfItems.count)", label: "TTF 字体")
            StatCard(icon: "internaldrive.fill", color: .blue, num: ByteCountFormatter.string(fromByteCount: store.totalSize, countStyle: .file), label: "占用空间")
            StatCard(icon: "checkmark.circle.fill", color: .green, num: lastBackupText, label: "上次备份")
        }
    }

    private var lastBackupText: String {
        guard let last = store.records.first else { return "暂无" }
        let f = DateFormatter(); f.dateFormat = "M/d HH:mm"
        return f.string(from: last.date)
    }

    private var filterPicker: some View {
        Picker("筛选", selection: $filter) {
            Text("全部").tag(BackupItemKind?.none)
            Text("HTML").tag(BackupItemKind?.some(.html))
            Text("TTF").tag(BackupItemKind?.some(.ttf))
        }
        .pickerStyle(.segmented)
    }

    private var sectionTitle: some View {
        HStack {
            Text("\(displayed.count) 个文件").font(.footnote.bold()).foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var fileList: some View {
        LazyVStack(spacing: 10) {
            ForEach(displayed) { item in
                NavigationLink {
                    FilePreviewView(item: item)
                } label: {
                    FileRow(item: item)
                }
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let color: Color
    let num: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text(num).font(.title2.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct FileRow: View {
    let item: BackupItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.kind.systemImage)
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(item.kind.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name).font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                Text("\(item.sizeString) · \(item.modifiedString)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
