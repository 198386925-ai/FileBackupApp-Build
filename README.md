# 文件备份 · 备份 HTML / TTF 文件的 iOS 应用

一个用 **SwiftUI** 编写的 iOS 应用，用于浏览、预览和备份设备上的 **HTML 文件** 与 **TTF 字体文件**，并支持导出分享。

> 想先看界面长什么样？直接用浏览器打开 `preview/index.html`（高保真 iOS UI 原型，可点击交互，支持深色模式切换）。

---

## 一、目录结构

```
FileBackupApp/
├── FileBackupApp/
│   ├── FileBackupAppApp.swift      # App 入口（@main）
│   ├── ContentView.swift           # TabView 主框架：浏览 / 备份 / 设置
│   ├── Info.plist                  # 应用配置（文档类型、后台模式）
│   ├── Models/
│   │   └── BackupItem.swift        # 数据模型：BackupItem / BackupRecord / BackupItemKind
│   ├── ViewModels/
│   │   └── BackupStore.swift       # 状态管理：扫描、备份、记录持久化
│   ├── Views/
│   │   ├── BrowserView.swift       # 浏览页：统计卡 + 分段筛选 + 文件列表
│   │   ├── FilePreviewView.swift   # 预览页：HTML(WebView) / TTF(字体样例)
│   │   ├── BackupView.swift        # 备份页：进度环 + 备份记录
│   │   └── SettingsView.swift      # 设置页
│   └── Utilities/
│       ├── FontLoader.swift        # 动态注册 TTF 并返回字体名
│       └── BackupFileManager.swift # 导入 / 导出 / 备份目录操作
└── preview/
    └── index.html                  # 网页版 UI 原型（无需 Xcode 即可查看）
```

## 二、在 Xcode 中编译出 IPA（两种方法）

### 方法 A：新建项目后拖入（推荐，最稳）
1. 打开 Xcode → `File ▸ New ▸ Project ▸ iOS ▸ App`。
2. Product Name 填 `FileBackupApp`，Interface 选 **SwiftUI**，Language 选 **Swift**。
3. 把本仓库 `FileBackupApp/FileBackupApp/` 下的所有 `.swift` 文件与 `Info.plist` 拖入项目（勾选 Add to targets）。
4. 添加 ZIPFoundation 依赖：Xcode 菜单 `File ▸ Add Package Dependencies`，输入 `https://github.com/weichsel/ZIPFoundation` 并添加（导出 ZIP 需要）。
5. 注意：不要把多余的 `Info.plist` 与 Xcode 自动生成的冲突——拖入后到 Target ▸ Build Settings 把 `Info.plist File` 指向你的 `Info.plist`。
6. 选择真机或模拟器，`⌘R` 运行；`⌘B` 归档后可导出 IPA。

### 方法 B：直接作为源码目录
将 `FileBackupApp/` 整体作为 Xcode 项目内容使用（适合已有工程结构时引用各分组）。

> 运行环境：iOS 16+，Swift 5.9+。TTF 动态注册依赖 `CoreText`，HTML 预览依赖 `WebKit`。

## 三、功能说明

| 功能 | 说明 |
| --- | --- |
| 文件扫描 | 自动扫描 `Documents` 下的 `.html/.htm` 与 `.ttf` 文件 |
| HTML 预览 | 用内嵌 `WKWebView` 渲染本地 HTML |
| TTF 预览 | 动态注册字体并显示「Aa / 中文 / 数字」样例 |
| 手动备份 | 将已上传文件复制到 `Documents/Backup`，记录备份历史 |
| 导出压缩包 | 备份后一键打包为 ZIP（ZIPFoundation），通过系统分享导出 |
| 分享导出 | 通过系统 `ShareLink` 调起分享面板 |
| 深色模式 | 跟随系统；网页原型可手动切换浅/深色 |

## 四、网页原型（preview/index.html）

- 在浏览器打开即可看到与 App 一致的界面。
- 点击文件卡片 → 底部弹出预览 Sheet（HTML 渲染 / 字体样例）。
- 右上角按钮切换**浅色 / 深色**模式。
- 底部 Tab 可在「浏览 / 备份 / 设置」间切换，备份页带进度环动画。

## 五、后续可扩展

- 接入 `ZIPFoundation` 实现真正的 ZIP 压缩导出。
- 接入 `FileDocument` / `DocumentPicker` 支持从「文件」App 导入。
- 接入 iCloud Drive（`UIDocumentPickerViewController`）做云备份。
