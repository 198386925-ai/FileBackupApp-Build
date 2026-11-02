import SwiftUI
import WebKit

/// 文件预览详情页：HTML 用内嵌 WebView 渲染，TTF 显示字体样例
struct FilePreviewView: View {
    let item: BackupItem
    @EnvironmentObject private var store: BackupStore
    @State private var fontName: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                infoCard
                previewArea
                actions
            }
            .padding(16)
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if item.kind == .ttf {
                fontName = FontLoader.postScriptName(for: item.url)
            }
        }
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: item.kind.systemImage)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(item.kind.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                VStack(alignment: .leading) {
                    Text(item.kind.displayName).font(.headline)
                    Text(item.path).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Divider()
            HStack {
                Label(item.sizeString, systemImage: "internaldrive")
                Spacer()
                Label(item.modifiedString, systemImage: "clock")
            }
            .font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var previewArea: some View {
        if item.kind == .html {
            HTMLWebView(url: item.url)
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 1))
        } else {
            ttfPreview
        }
    }

    private var ttfPreview: some View {
        VStack(spacing: 16) {
            Text("Aa").font(customFont(size: 72)).frame(maxWidth: .infinity, alignment: .center)
            Text("永字八法 Typography 123").font(customFont(size: 32))
                .frame(maxWidth: .infinity, alignment: .center)
            Text("包罗万象 0 1 2 3 4 5 6 7 8 9").font(customFont(size: 18))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(28)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func customFont(size: CGFloat) -> Font {
        if let name = fontName { return Font.custom(name, size: size) }
        return Font.system(size: size)
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                store.addToBackup(item)
            } label: {
                Label("加入备份", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            ShareLink(item: item.url) {
                Label("分享", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

/// 用 WKWebView 渲染本地 HTML 文件
struct HTMLWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.isOpaque = false
        wv.backgroundColor = .clear
        wv.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
