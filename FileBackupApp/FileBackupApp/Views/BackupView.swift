import SwiftUI

struct BackupView: View {
    @EnvironmentObject private var store: BackupStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    hero
                    if !store.records.isEmpty {
                        recordsSection
                    }
                }
                .padding(16)
            }
            .navigationTitle("备份中心")
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("备份已上传的文件").font(.title3.bold())
                    Text("将 HTML 与 TTF 复制到 Backup 目录，便于导出与恢复")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                ProgressRing(progress: store.backupProgress)
                    .frame(width: 64, height: 64)
            }

            Button {
                Task { await store.backupAll() }
            } label: {
                if store.isBackingUp {
                    ProgressView("备份中… \(Int(store.backupProgress * 100))%")
                        .tint(.blue)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("开始备份").font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(store.isBackingUp)

            if let url = store.lastArchiveURL {
                ShareLink("导出 / 分享压缩包", item: url)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
            }

            if let msg = store.lastMessage {
                Text(msg).font(.caption).foregroundStyle(.green)
            }
        }
        .padding(22)
        .background(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .foregroundStyle(.white)
    }

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("备份记录").font(.footnote.bold()).foregroundStyle(.secondary)
            VStack(spacing: 0) {
                ForEach(Array(store.records.enumerated()), id: \.element.id) { idx, rec in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(rec.fileCount == 0 ? "增量备份" : "完整备份").font(.system(size: 15, weight: .medium))
                            Text(recordDate(rec.date)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(rec.fileCount) 个文件").font(.subheadline).foregroundStyle(.green).bold()
                    }
                    .padding(.vertical, 13)
                    if idx < store.records.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func recordDate(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm"
        return f.string(from: d)
    }
}

/// 圆形进度环
struct ProgressRing: View {
    let progress: Double
    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.3), lineWidth: 6)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}
