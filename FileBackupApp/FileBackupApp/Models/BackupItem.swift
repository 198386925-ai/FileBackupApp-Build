import Foundation
import SwiftUI

/// 备份文件的类型
enum BackupItemKind: String, Codable, CaseIterable {
    case html
    case ttf

    var displayName: String {
        switch self {
        case .html: return "HTML 文件"
        case .ttf: return "TTF 字体"
        }
    }

    var systemImage: String {
        switch self {
        case .html: return "doc.richtext.fill"
        case .ttf: return "f.cursive"
        }
    }

    var accentColor: Color {
        switch self {
        case .html: return .orange
        case .ttf: return .purple
        }
    }
}

/// 一个被管理的备份文件（HTML 或 TTF）
struct BackupItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var path: String          // 相对 Documents 的路径
    var kind: BackupItemKind
    var size: Int64           // 字节
    var modifiedAt: Date

    var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(path)
    }

    var sizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var modifiedString: String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "zh_CN")
        return f.localizedString(for: modifiedAt, relativeTo: Date())
    }

    static func make(name: String, path: String, kind: BackupItemKind, size: Int64, modifiedAt: Date) -> BackupItem {
        BackupItem(id: UUID(), name: name, path: path, kind: kind, size: size, modifiedAt: modifiedAt)
    }
}

/// 一次备份记录
struct BackupRecord: Identifiable, Codable {
    let id: UUID
    var date: Date
    var fileCount: Int
    var totalSize: Int64
    var destination: String
}
