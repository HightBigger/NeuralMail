//
//  NMEmailConfigLoader.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/17.
//

import Foundation
import NMModular

// MARK: - Email Configuration Models

public struct NMEmailProviderConfig: Codable {
    public let version: Int
    public let providers: [NMEmailProvider]
}

public struct NMEmailProvider: Codable {
    public let id: String
    public let name: String
    public let domains: [String]
    public let incoming: NMServerInfo
    public let outgoing: NMServerInfo
    public let specialNote: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, domains, incoming, outgoing
        case specialNote = "special_note"
    }
}

public struct NMServerInfo: Codable {
    public let host: String
    public let port: Int
    public let security: String // "ssl" or "starttls" or "none"
}

extension NMServerInfo {
    // 计算属性：判断是否是安全连接
    var isSecure: Bool {
        let type = security.lowercased()
        return type == "ssl" || type == "starttls"
    }
}

// MARK: - Helper Class

public class NMEmailConfigLoader {
    
    @NMLogger("NMAuthModule") var logger
    
    public static let shared = NMEmailConfigLoader()
    
    private var providers: [NMEmailProvider] = []
    
    public lazy var allDomains: [String] = {
        let all = providers.flatMap { $0.domains }
        return Array(Set(all)).sorted() // 去重并排序
    }()
    
    private init() {
        loadConfig()
    }
    
    private func loadConfig() {
        
        guard let url = URL.authResource(name:"email_providers",ext:"json"),let data = try? Data(contentsOf: url) else {
            
            logger.error("❌ Failed to load email_providers.json")
            
            return
        }
        
        do {
            let config = try JSONDecoder().decode(NMEmailProviderConfig.self, from: data)
            self.providers = config.providers
        } catch {
            logger.error("❌ JSON Decode Error: \(error)")
        }
    }
    
    
    /// 根据邮箱地址查找配置
    /// - Parameter email: 用户输入的完整邮箱 (e.g. "test@qq.com")
    /// - Returns: 匹配到的配置对象，若未找到则返回 nil
    public func findProvider(for email: String) -> NMEmailProvider? {
        let components = email.split(separator: "@")
        guard components.count == 2 else { return nil }
        
        
        let domain = String(components[1]).lowercased().trimmingCharacters(in: .whitespaces)
        
        return providers.first { provider in
            provider.domains.contains { configDomain in
                configDomain.lowercased() == domain
            }
        }
    }
}
