//
//  NMKeychain.swift
//  Pods
//
//  Created by 小大 on 2025/12/24.
//

import Foundation
import Security

/// 简单的 Keychain 封装，用于存储邮箱密码/Token
public class NMKeychain {
    
    // MARK: - Configuration
    
    // 使用 App 的 Bundle ID 作为服务标识，防止与其他 App 冲突
    private static let serviceName = Bundle.main.bundleIdentifier
    
    // MARK: - Public API
    
    /// 保存密码 (如果已存在则覆盖)
    /// - Parameters:
    ///   - password: 密码或 Token 字符串
    ///   - account: 账号 (通常是邮箱地址)
    public static func save(password: String, for account: String) -> Bool {
        guard let data = password.data(using: .utf8) else { return false }
        
        // 1. 准备查询条件
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName!,
            kSecAttrAccount as String: account
        ]
        
        // 2. 尝试删除旧数据 (这是处理“更新”最简单粗暴且有效的方法)
        SecItemDelete(query as CFDictionary)
        
        // 3. 添加新数据
        var newQuery = query
        newQuery[kSecValueData as String] = data
        
        // 默认设置为：设备解锁后可访问 (兼顾安全与后台收信需求)
        // 如果你需要极高安全性，可以用 kSecAttrAccessibleWhenUnlocked
        // 如果你需要后台收信，建议用 kSecAttrAccessibleAfterFirstUnlock
        newQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        
        let status = SecItemAdd(newQuery as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// 获取密码
    /// - Parameter account: 账号 (邮箱地址)
    /// - Returns: 密码字符串，如果没找到返回 nil
    public static func get(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName!,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,       // 要求返回数据
            kSecMatchLimit as String: kSecMatchLimitOne // 只取一条
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return password
    }
    
    /// 删除密码
    public static func delete(for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName!,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    /// 清空所有密码 (通常用于卸载重装或重置 App)
    public static func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName!
        ]
        SecItemDelete(query as CFDictionary)
    }
}
