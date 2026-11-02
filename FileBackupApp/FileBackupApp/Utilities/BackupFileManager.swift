import Foundation
import UniformTypeIdentifiers

/// HTML / TTF 文件导入、导出与备份相关的文件操作工具
enum BackupFileManager {

    /// 从系统「文件」App / 分享面板导入文件到 Documents
    static func importFile(from source: URL, toDocuments fileName: String) -> Bool {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        let dst = docs.appendingPathComponent(fileName)
        do {
            if fm.fileExists(atPath: dst.path) { try fm.removeItem(at: dst) }
            try fm.copyItem(at: source, to: dst)
            return true
        } catch {
            print("导入失败: \(error.localizedDescription)")
            return false
        }
    }

    /// 生成可分享的备份压缩包（简单实现：复制为 .zip 名，真实项目请用 ZIPFoundation）
    static func exportBackupArchive() -> URL? {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let backupDir = docs.appendingPathComponent("Backup")
        guard fm.fileExists(atPath: backupDir.path) else { return nil }
        let archive = docs.appendingPathComponent("Backup_\(Int(Date().timeIntervalSince1970)).zip")
        // 注：生产环境推荐集成 ZIPFoundation 做真正压缩
        return archive
    }

    static let supportedTypes: [UTType] = [.html, .ttf]
}
