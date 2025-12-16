//
//  NMAuthServiceImpl.swift
//  NMModular
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import NMModular

final class NMAuthServiceImpl: NMAuthService {
    
    // ✅ 自动注入带模块名的日志: [Auth] [INFO] ...
    @NMLogger("AuthModule") var logger
    
    // 注入基础设施
    @NMInjected var network: NMNetworkService
    @NMInjected var db: NMDatabaseService
    
    // 内存缓存
    private(set) var currentUser: NMUser?
    
    var isLoggedIn: Bool {
        return accessToken != nil
    }
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "nm_access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "nm_access_token") }
    }
    
    init() {
        // 尝试恢复会话
        Task { await restoreSession() }
    }
    
    // MARK: - 登录逻辑
    
    func login(email: String, password: String) async throws {
        logger.info("Login start: \(email)")
        
        // 1. 网络请求
        let response: NMLoginResponse = try await network.request(NMAuthAPI.login(email: email, pass: password))
        
        // 2. 持久化 Token
        self.accessToken = response.token
        
        // 3. ✅ 持久化 User (完全解耦的调用)
        // 不需要 import GRDB，直接把 Model 扔给 Data 模块
        try await db.save(response.user)
        
        // 4. 更新状态
        self.currentUser = response.user
        
        // 5. 通知
        NMModuleManager.shared.userDidLogin(userId: response.user.id)
        NotificationCenter.default.post(name: .NMUserDidLogin, object: nil)
        
        logger.info("Login success")
    }
    
    // MARK: - 登出逻辑
    
    func logout() async {
        logger.info("Logging out...")
         
        // 1. 尝试发送网络请求 (Best Effort)
        // 使用 do-catch 捕获错误，防止因网络失败导致函数中断，从而没走到下面的清理逻辑
        do {
            // 注意：这里假设 NMLogoutResponse 已经在 DTO 文件中定义
            let response: NMLogoutResponse = try await network.request(NMAuthAPI.logout)
            
            if !response.ret {
                logger.warn("Server returned failure for logout, but clearing local session anyway.")
            }
        } catch {
            // 如果断网了，这里会报错，我们要捕获它，不要让它抛给上层
            logger.error("Logout network request failed: \(error). Proceeding with local cleanup.")
        }
        
        // 2. 清理本地
        self.accessToken = nil
        self.currentUser = nil
        
        // 3. 通知
        NMModuleManager.shared.userDidLogout()
        NotificationCenter.default.post(name: .NMUserDidLogout, object: nil)
        logger.info("Local session cleared.")
    }
    
    // MARK: - 辅助方法
    
    private func restoreSession() async {
        guard isLoggedIn else { return }
        
        // 假设我们在 UserDefault 存了当前用户的 ID
        guard let uid = UserDefaults.standard.string(forKey: "current_user_id") else { return }
        
        // ✅ 泛型读取用户信息
        do {
            if let user = try await db.fetch(NMUser.self, id: uid) {
                self.currentUser = user
                logger.debug("Session restored for user: \(user.email)")
            }
        } catch {
            logger.error("Failed to restore session: \(error)")
        }
    }
}
