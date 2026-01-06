//
//  NMMailSidebarViewModel.swift
//  NMFeatureModule
//
//  Created by 小大 on 2026/1/5.
//

// NMMailSidebarViewModel.swift

import UIKit
import Combine
import NMModular // 假设 NMMailFolder 在这里

enum SidebarItem: Hashable {
    case header(String) // 分组标题
    case folder(NMMailFolderItem) // 具体的文件夹数据
}

struct NMMailFolderItem: Hashable {
    let path: String       // 唯一标识 (用于选中逻辑)
    let displayName: String // 显示名称
    let iconName: String   // SF Symbol 名字
    let iconColor: UIColor? // 图标颜色 (系统文件夹用)
    let unreadCount: Int
    let isSystem: Bool     // 是否是系统文件夹
}

class NMMailSidebarViewModel: ObservableObject {
    
    @NMInjected private var featureService: NMFeatureService
    @NMInjected private var folderRepository: NMMailFolderRepository
    @NMInjected private var authService: NMAuthService
    
    // Outputs
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, SidebarItem>?
    
    // Inputs
    private var allFolders: [NMMailFolder] = []
    private var selectedPath: String
    
    init(selectedPath: String) {
        self.selectedPath = selectedPath
        loadFolders()
    }
    
    private func loadFolders() {
        guard let config = authService.currentConfig else { return }
        
        Task {
            do {
                // 1. 从数据库读取
                let folders = try await folderRepository.getFolders(forAccount: config.email)
                self.allFolders = folders
                
                // 2. 构建 UI 数据 (切回主线程)
                await buildSnapshot(folders: folders)
                
            } catch {
                print("❌ [Sidebar] 加载文件夹失败: \(error)")
            }
        }
    }
    
    @MainActor
    private func buildSnapshot(folders:[NMMailFolder]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SidebarItem>()
        
        // 1. 筛选系统文件夹 (Inbox, Sent, Drafts, Trash, Junk)
        // 这里根据 Flags 或 Path 关键字判断
        let systemFolders = allFolders.filter { isSystemFolder($0) }
            .sorted { sortSystemFolders($0, $1) }
            .map { convertToItem($0, isSystem: true) }
        
        if !systemFolders.isEmpty {
            snapshot.appendSections([0])
            snapshot.appendItems(systemFolders.map { .folder($0) }, toSection: 0)
        }
        
        // 2. 筛选自定义文件夹
        let customFolders = allFolders.filter { !isSystemFolder($0) }
            .sorted { $0.displayName < $1.displayName }
            .map { convertToItem($0, isSystem: false) }
        
        if !customFolders.isEmpty {
            snapshot.appendSections([1])
            // snapshot.appendItems([.header("我的文件夹")], toSection: 1) // 可选标题
            snapshot.appendItems(customFolders.map { .folder($0) }, toSection: 1)
        }
        
        self.snapshot = snapshot
    }
    
    // MARK: - Public Helper
    /// 根据 UI 选中的 ID 找回原始业务对象
    func getFolder(by path: String) -> NMMailFolder? {
        return allFolders.first { $0.path == path }
    }
    
    // MARK: - Helper Logic
    
    private func convertToItem(_ folder: NMMailFolder, isSystem: Bool) -> NMMailFolderItem {
        let (icon, color) = getIconAndColor(for: folder)
        return NMMailFolderItem(
            path: folder.path,
            displayName: folder.displayName, // 记得用之前修好的 imapDecoded
            iconName: icon,
            iconColor: isSystem ? color : .secondaryLabel,
            unreadCount: 0, // 暂时写0，后续从数据库读
            isSystem: isSystem
        )
    }
    
    private func getIconAndColor(for folder: NMMailFolder) -> (String, UIColor) {
        // 优先判断 Flag
        if folder.flags.contains(.inbox) { return ("tray.fill", .systemBlue) }
        if folder.flags.contains(.drafts) { return ("doc.fill", .systemOrange) }
        if folder.flags.contains(.sent) { return ("paperplane.fill", .systemGreen) }
        if folder.flags.contains(.trash) { return ("trash.fill", .systemRed) }
        if folder.flags.contains(.junk) { return ("xmark.bin.fill", .systemBrown) }
        if folder.flags.contains(.flagged) { return ("flag.fill", .systemOrange) }
        
        // 其次判断名称 (兜底)
        let lowerName = folder.path.lowercased()
        if lowerName.contains("inbox") { return ("tray.fill", .systemBlue) }
        if lowerName.contains("sent") { return ("paperplane.fill", .systemGreen) }
        
        // 默认文件夹
        return ("folder", .secondaryLabel)
    }
    
    private func isSystemFolder(_ folder: NMMailFolder) -> Bool {
        // 根据业务逻辑定义哪些算系统文件夹
        let flags = folder.flags
        return flags.contains(.inbox) || flags.contains(.sent) || flags.contains(.drafts) || flags.contains(.trash) || flags.contains(.junk)
    }
    
    // 系统排序权重
    private func sortSystemFolders(_ f1: NMMailFolder, _ f2: NMMailFolder) -> Bool {
        func score(_ f: NMMailFolder) -> Int {
            let flags = NMMailFolderFlags(rawValue: f.flags.rawValue)
            if flags.contains(.inbox) || f.path.lowercased() == "inbox" { return 0 }
            if flags.contains(.sent) { return 1 }
            if flags.contains(.drafts) { return 2 }
            if flags.contains(.junk) { return 3 }
            if flags.contains(.trash) { return 4 }
            return 99
        }
        return score(f1) < score(f2)
    }
    
    private func translateSystemName(_ folder: NMMailFolder, decoded: String) -> String {
        // 简单本地化
        if folder.path.lowercased() == "inbox" { return "收件箱" }
        // 其他的可以用 decoded，因为如果是 &Xf... 解码后本身就是中文
        return decoded
    }
}
