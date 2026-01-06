//
//  NMFeatureServiceImpl.swift
//  NMFeatureModule
//
//  Created by 小大 on 2025/12/25.
//

import Foundation
import NMModular

/// 邮件主页业务服务实现
public class NMFeatureServiceImpl: NMFeatureService {
    
    // MARK: - Dependencies
    
    // 注入底层邮件服务 (Infra Layer)
    // 依赖 NMModular 中的 NMMailService 接口
    @NMInjected private var mailService: NMMailService
    @NMInjected private var authService: NMAuthService
    
    @NMInjected private var mailFolderRepository: NMMailFolderRepository
    
    @NMLogger("NMFeatureModule") private var logger
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Business Logic
    
    public func fetchLatestMessages(folder: String, limit : Int, offset: Int) async throws -> [NMMailMessage] {
        logger.debug("开始拉取主页邮件: offset=\(offset), limit=\(limit)")
        
        try await ensureConnection()
   
        let msgs = try await mailService.fetchMessages(folder:folder,offset: offset, limit: limit)
        
        return msgs
    }
    
    public func fetchSideBarFolders() async throws -> [NMMailFolder] {
        logger.debug("正在刷新侧边栏文件夹...")
        
        let folders = try await mailService.fetchFolders()
        
        try await mailFolderRepository.saveFolders(folders, forAccount: authService.currentConfig!.email)
        
        return folders
    }
    
    public func searchMessages(keyword: String) async throws -> [NMMailMessage] {
        logger.info("执行搜索: \(keyword)")
        // 这里假设底层 NMMailService 后续会补充 search 接口
        // 目前返回空数组作为占位
        return []
    }
    
    // MARK: - Private Logic
    /// 核心封装：拉取邮件前，确保连接可用
    private func ensureConnection() async throws {
       
        if mailService.isConnected {
            return
        }
        
        // 2. 如果没连上，尝试获取配置进行“静默连接”
        guard (authService.currentConfig) != nil else {
            // 连配置都没有（比如被登出了），抛出认证错误
            throw NSError(domain: "NMFeature", code: 401, userInfo: [NSLocalizedDescriptionKey: "无有效账户配置"])
        }
        
        logger.info("检测到未连接，正在发起静默连接...")
        try await _ = authService.syncAccount()
    }
}
