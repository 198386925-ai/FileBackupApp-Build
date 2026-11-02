import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: BackupStore
    @State private var selectedTab: Tab = .browse

    enum Tab: Hashable {
        case browse
        case backup
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            BrowserView()
                .tabItem { Label("浏览", systemImage: "folder.fill") }
                .tag(Tab.browse)

            BackupView()
                .tabItem { Label("备份", systemImage: "arrow.up.doc.fill") }
                .tag(Tab.backup)

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
        .accentColor(.blue)
        .environmentObject(store)
    }
}
