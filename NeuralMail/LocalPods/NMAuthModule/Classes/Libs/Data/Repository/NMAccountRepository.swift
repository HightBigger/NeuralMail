//
//  NMAccountRepository.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/25.
//

import Foundation
import NMModular
import NMKit

class NMAccountRepository {
    
    @NMLogger("NMAuthModule") var logger
    
//    public static let shared = NMAccountRepository()
    
    private let storage = UserDefaults.standard
    private let storageKey = "nm_saved_accounts"

    
    // MARK: - Save (登录成功调用)
    
    /// 保存账号信息
    /// - Parameters:
    ///   - user: 用户信息
    ///   - config: 包含密码的完整配置
    public func saveAccount(user: NMUser, config: NMMailConfig) {
        
        // 1. 【核心安全步骤】把密码存入 Keychain
        // 使用 email 作为唯一索引
        let isKeychainSaved = NMKeychain.save(password: config.password, for: user.email)
        if !isKeychainSaved {
            logger.error(" [NMAccountRepository] 严重警告：Keychain 写入失败")
        }
        
        // 2. 【脱敏处理】创建一个不含密码的 Config 副本存入 UserDefaults
        // 因为你的 NMMailConfig 属性是 let，所以必须重新 init
        let safeConfig = NMMailConfig(
            email: config.email,
            host: config.host,
            port: config.port,
            ssl: config.ssl,
            username: config.username,
            password: "", // 强制置空！
            protocolType: config.protocolType
        )
        
        // 3. 读取旧数据并更新
        var accounts = loadAllEntities()
        
        // 如果已存在该用户，先删除旧的
        accounts.removeAll { $0.user.email == user.email }
        
        // 将其他账号设为非活跃 (单账号逻辑)
        for i in 0..<accounts.count {
            accounts[i].isCurrent = false
        }
        
        // 4. 追加新账号
        let newEntity = NMAccountEntity(user: user, config: safeConfig, isCurrent: true)
        accounts.append(newEntity)
        
        // 5. 写入磁盘
        persist(accounts)
        
        logger.info("💾 [NMAccountRepository] 账号已安全存储: \(user.email)")
    }
    
    // MARK: - Load (App启动/自动登录调用)
    
    /// 获取当前活跃账号的完整信息 (自动填充密码)
    /// - Returns: 元组 (User, FullConfig)
    public func getCurrentAccount() -> (user: NMUser, config: NMMailConfig)? {
        guard let entity = loadAllEntities().first(where: { $0.isCurrent }) else {
            return nil
        }
        
        // 1. 从磁盘拿到的 config (密码是空的)
        let safeConfig = entity.config
        
        // 2. 从 Keychain 拿回密码
        guard let password = NMKeychain.get(for: entity.user.email) else {
            logger.error("[NMAccountRepository] 找到用户但丢失密码: \(entity.user.email)")
            return nil
        }
        
        // 3. 【重组】将密码填回去，生成完整对象供 MailCore 使用
        let fullConfig = NMMailConfig(
            email: safeConfig.email,
            host: safeConfig.host,
            port: safeConfig.port,
            ssl: safeConfig.ssl,
            username: safeConfig.username,
            password: password,
            protocolType: safeConfig.protocolType
        )
        
        return (entity.user, fullConfig)
    }
    
    /// 退出登录
    public func logoutCurrent() {
        var accounts = loadAllEntities()
        if let index = accounts.firstIndex(where: { $0.isCurrent }) {
            _ = accounts[index].user.email
            accounts[index].isCurrent = false
            persist(accounts)
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadAllEntities() -> [NMAccountEntity] {
        guard let data = storage.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([NMAccountEntity].self, from: data)) ?? []
    }
    
    private func persist(_ accounts: [NMAccountEntity]) {
        if let data = try? JSONEncoder().encode(accounts) {
            storage.set(data, forKey: storageKey)
        }
    }
}
