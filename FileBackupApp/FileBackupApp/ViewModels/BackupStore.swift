import Foundation
import Combine
// 注意：导出 ZIP 依赖 ZIPFoundation，请在 Xcode 中通过
// File ▸ Add Package Dependencies 添加 https://github.com/weichsel/ZIPFoundation
import ZIPFoundation

/// 全局状态：扫描文件、上传导入、备份与导出
final class BackupStore: ObservableObject {
    @Published var items: [BackupItem] = []
    @Published var records: [BackupRecord] = []
    @Published var isBackingUp = false
    @Published var backupProgress: Double = 0
    @Published var lastMessage: String?
    @Published var lastArchiveURL: URL?

    private let fileManager = FileManager.default
    private let recordsKey = "com.filebackup.records"

    init() {
        scan()
        loadRecords()
    }

    // MARK: - 扫描 Documents 下的 HTML / TTF 文件
    func scan() {
        guard let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        var result: [BackupItem] = []

        let enumerator = fileManager.enumerator(at: docs, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey], options: [.skipsHiddenFiles])
        while let url = enumerator?.nextObject() as? URL {
            guard url.isFileURL else { continue }
            let ext = url.pathExtension.lowercased()
            guard ext == "html" || ext == "htm" || ext == "ttf" else { continue }

            let kind: BackupItemKind = (ext == "ttf") ? .ttf : .html
            let resource = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
            let size = Int64(resource?.fileSize ?? 0)
            let modified = resource?.contentModificationDate ?? Date()
            let relative = url.path.replacingOccurrences(of: docs.path + "/", with: "")

            result.append(.make(name: url.lastPathComponent, path: relative, kind: kind, size: size, modifiedAt: modified))
        }
        items = result.sorted { $0.modifiedAt > $1.modifiedAt }
    }

    var htmlItems: [BackupItem] { items.filter { $0.kind == .html } }
    var ttfItems: [BackupItem] { items.filter { $0.kind == .ttf } }
    var totalSize: Int64 { items.reduce(0) { $0 + $1.size } }

    // MARK: - 备份（复制到 Documents/Backup 目录）
    func backupAll() async {
        await MainActor.run { isBackingUp = true; backupProgress = 0; lastMessage = nil }
        guard let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let backupDir = docs.appendingPathComponent("Backup")

        try? fileManager.createDirectory(at: backupDir, withIntermediateDirectories: true)
        let total = items.count
        var done = 0
        var copied = 0

        for item in items {
            let src = item.url
            let dst = backupDir.appendingPathComponent(item.name)
            do {
                if fileManager.fileExists(atPath: dst.path) {
                    try fileManager.removeItem(at: dst)
                }
                try fileManager.copyItem(at: src, to: dst)
                copied += 1
            } catch {
                print("备份失败: \(item.name) -> \(error.localizedDescription)")
            }
            done += 1
            let p = Double(done) / Double(max(total, 1))
            await MainActor.run { backupProgress = p }
        }

        let record = BackupRecord(id: UUID(), date: Date(), fileCount: copied, totalSize: totalSize, destination: backupDir.path)
        await MainActor.run {
            records.insert(record, at: 0)
            saveRecords()
            lastArchiveURL = buildArchive()
            isBackingUp = false
            lastMessage = "已备份 \(copied) 个文件到 Backup 目录"
        }
    }

    func addToBackup(_ item: BackupItem) {
        lastMessage = "已将 \(item.name) 加入备份队列"
    }

    /// 用户主动上传 / 导入文件（来自系统文件选择器，需安全作用域访问）
    func importFiles(from urls: [URL]) {
        var imported = 0
        for url in urls {
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            let ext = url.pathExtension.lowercased()
            guard ["html", "htm", "ttf"].contains(ext) else { continue }
            let kind: BackupItemKind = (ext == "ttf") ? .ttf : .html
            let name = url.lastPathComponent
            let dst = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(name)
            do {
                if FileManager.default.fileExists(atPath: dst.path) {
                    try FileManager.default.removeItem(at: dst)
                }
                try FileManager.default.copyItem(at: url, to: dst)
                imported += 1
            } catch {
                print("导入失败: \(name) -> \(error.localizedDescription)")
            }
        }
        scan()
        lastMessage = imported > 0 ? "已上传 \(imported) 个文件" : "没有可上传的文件"
    }

    // MARK: - 导出 ZIP 压缩包（依赖 ZIPFoundation）
    /// 将 Backup 目录打包为 .zip 返回其 URL，供分享 / 导出
    func buildArchive() -> URL? {
        guard let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let backupDir = docs.appendingPathComponent("Backup")
        guard fileManager.fileExists(atPath: backupDir.path) else { return nil }
        let zipURL = docs.appendingPathComponent("Backup_\(Int(Date().timeIntervalSince1970)).zip")
        try? fileManager.removeItem(at: zipURL)
        guard let archive = Archive(url: zipURL, accessMode: .create) else { return nil }
        let enumerator = fileManager.enumerator(at: backupDir, includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            guard url.isFileURL, !url.hasDirectoryPath else { continue }
            let relative = url.path.replacingOccurrences(of: backupDir.path + "/", with: "")
            do {
                try archive.addEntry(with: relative, fileURL: url)
            } catch {
                print("打包失败: \(relative) -> \(error.localizedDescription)")
            }
        }
        return zipURL
    }

    // MARK: - 记录持久化
    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: recordsKey)
        }
    }

    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: recordsKey),
              let decoded = try? JSONDecoder().decode([BackupRecord].self, from: data) else { return }
        records = decoded
    }
}
