import CoreText
import Foundation

/// 动态注册 TTF 字体文件并返回其 PostScript 名称，供 SwiftUI 预览使用
enum FontLoader {
    /// 返回字体 PostScript 名称（用于 Font.custom(name:, size:)）
    static func postScriptName(for url: URL) -> String? {
        guard let data = try? Data(contentsOf: url),
              let provider = CGDataProvider(data: data as CFData),
              let cgFont = CGFont(provider) else { return nil }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(cgFont, &error)
        // 即便已注册（重复注册失败），字体已存在，可直接取名字
        return cgFont.postScriptName as String?
    }

    /// 返回字体族中可用的样例：使用已注册字体渲染的大字
    static func previewFont(for url: URL, size: CGFloat) -> Font? {
        guard let name = postScriptName(for: url) else { return nil }
        return Font.custom(name, size: size)
    }
}
