//
//  NMAuthServiceImpl.swift
//  NMModular
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import NMModular
import NMKit

final class NMAuthServiceImpl: NMAuthService {
    
    @NMLogger("NMAuthModule") var logger
    @NMInjected var mailService: NMMailService
    @NMInjected var accountRepository: NMAccountRepository

    // 注入基础设施
    @NMInjected var network: NMNetworkService
    @NMInjected var db: NMDatabaseService
    
    // 内存缓存
    private(set) var currentUser: NMUser?
    private(set) var currentConfig:NMMailConfig?
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "nm_access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "nm_access_token") }
    }
    
    init() {
        // 尝试恢复会话
        restoreSession()
    }
    
    // MARK: - 登录逻辑
    func syncAccount() async throws {
        
        guard let config = currentConfig else { return }
        
        logger.info("syncAccount start: \(config.email)")
        
        try await mailService.connect(config: config)
        
        logger.info("syncAccount 连接成功: \(config.username)")
    }
    
    
    func login(config: NMMailConfig) async throws {
        
        logger.info("Login start: \(config.email)")
        
        try await mailService.connect(config: config)
        logger.info("Auth模块 连接成功: \(config.username)")
        
        let newUser = NMUser(email: config.email)
        accountRepository.saveAccount(user: newUser, config: config)
        
        self.currentUser = newUser
        self.currentConfig = config
        
        NMModuleManager.shared.userDidLogin(userId: newUser.id)
        NotificationCenter.default.post(name: .NMUserDidLogin, object: nil)
        
        logger.info("Login success")
    }
    
    // MARK: - 登出逻辑
    
    func logout() async {
        logger.info("Logging out...")
         
        self.accessToken = nil
        self.currentUser = nil
        
        accountRepository.logoutCurrent()
        
        // 3. 通知
        NMModuleManager.shared.userDidLogout()
        NotificationCenter.default.post(name: .NMUserDidLogout, object: nil)
        logger.info("Local session cleared.")
    }
    
    // MARK: - 辅助方法
    
    private func restoreSession() {
        
        if let account = accountRepository.getCurrentAccount() {
            
            self.currentUser = account.user        // NMUser 对象
            self.currentConfig = account.config       // NMMailConfig 对象 (包含解密后的 password)
            
            logger.info("当前登录用户: \(self.currentUser!.email)")
            logger.info("IMAP 主机: \(self.currentConfig!.host)")
            
        } else {
            logger.info("未找到有效账号，请跳转登录页")
        }
    }
}
