import SwiftUI

@main
struct FileBackupAppApp: App {
    @StateObject private var store = BackupStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                // 不强制浅/深色，跟随系统设置，原生支持深色模式
                .preferredColorScheme(nil)
        }
    }
}
