//
//  NMMailHomeViewModel.swift
//  NMFeatureHome
//
//  Created by NeuralMail on 2025/12/30.
//

import Foundation
import Combine
import NMModular
import NMKit

public class NMMailHomeViewModel: ObservableObject {
    
    // MARK: - 依赖注入
    @NMInjected private var featureService: NMFeatureService
    @NMInjected private var folderRepository: NMMailFolderRepository
    @NMInjected private var authService: NMAuthService
    
    @NMLogger("NMFeatureModule") private var logger
    
    // MARK: - UI 状态 (Outputs)
    
    // 列表数据源
    @Published var items: [NMMailMessage] = []
    
    // 页面状态 (Idle, Loading, Error, etc.)
    enum ViewState: Equatable {
        case idle
        case loading // 全屏或下拉刷新中
        case empty   // 无数据
        case error(String)
    }
    @Published var state: ViewState = .idle
    
    // 是否正在加载更多 (用于底部 Loading 控件)
    @Published var isLoadingMore: Bool = false
    
    @Published var folderDisplayName: String = "收件箱"
    
    var currentFolder: NMMailFolder?
    var currentPath: String {
        return currentFolder?.path ?? "INBOX"
    }
    // MARK: - 内部属性
    
    private var currentPage = 0
    private let pageSize = 20
    private var hasMoreData = true
    
    // MARK: - Actions
    
    /// 初始化加载或下拉刷新
    func refresh() {
        guard state != .loading else { return }
        
        // 重置分页状态
        currentPage = 0
        hasMoreData = true
        state = .loading
        
        Task {
            if currentFolder == nil {
                await setupCurrentFolder()
            }
    
            await fetchMessages(isLoadMore: false)
            
            _ = try await featureService.fetchSideBarFolders()
        }
    }
    
    /// 上拉加载更多
    func loadMore() {
        guard hasMoreData, !isLoadingMore, state != .loading else { return }
        
        isLoadingMore = true
        
        Task {
            await fetchMessages(isLoadMore: true)
        }
    }
    
    func switchFolder(_ folder: NMMailFolder) {
        print("🔄 [Home] 切换到文件夹: \(folder.displayName)")
        
        // 1. 更新当前状态
        self.currentFolder = folder
        // imapDecoded 在这里再次发挥作用
        self.folderDisplayName = folder.displayName
        
        // 2. 清空数据并重置分页
        self.items = []
        self.currentPage = 0
        self.hasMoreData = true
        
        // 3. 触发刷新 (UI 会自动转菊花)
        self.refresh()
    }
    
    // MARK: - Private Logic
    private func setupCurrentFolder() async {
        guard let user = authService.currentUser else { return }
        
        do {
            // 从数据库获取该账号下所有文件夹
            let folders = try await folderRepository.getFolders(forAccount: user.email)
                        
            if let inbox = folders.first(where: { $0.isInbox }) {
                self.currentFolder = inbox
                await MainActor.run {
                    self.folderDisplayName = inbox.displayName
                }
                logger.info("[HomeVM] 锁定收件箱: \(inbox.path) (\(inbox.displayName))")
            }else
            {
                logger.info("[HomeVM] 数据库未找到收件箱，使用默认 INBOX")
            }
     
        } catch {
            logger.error("[HomeVM] 读取文件夹失败: \(error)")
        }
    }
    
    
    private func fetchMessages(isLoadMore: Bool) async {
        do {
            // 计算 offset
            let offset = isLoadMore ? items.count : 0
            
            let newMessages = try await featureService.fetchLatestMessages(folder: currentPath, limit: pageSize, offset: offset)
            
            await MainActor.run {
                if isLoadMore {
                    // 追加模式
                    if newMessages.isEmpty {
                        self.hasMoreData = false
                    } else {
                        self.items.append(contentsOf: newMessages)
                    }
                    self.isLoadingMore = false
                } else {
                    // 刷新模式
                    self.items = newMessages
                    self.hasMoreData = !newMessages.isEmpty
                    
                    if self.items.isEmpty {
                        self.state = .empty
                    } else {
                        self.state = .idle
                    }
                }
            }
        } catch {
            await MainActor.run {
                if isLoadMore {
                    self.isLoadingMore = false
                    // 加载更多失败通常只提示 Toast，不改变全屏状态
                    // 这里可以通过另一个 Subject 发送一次性错误事件
                } else {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
}
