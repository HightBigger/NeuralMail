//
//  NMMail.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/25.
//

// [NMData Module] / Models / NMAccountEntity.swift

import Foundation
import NMModular

/// 用于持久化存储的账号实体 (Data Transfer Object)
struct NMAccountEntity: Codable {
    let user: NMUser
    var config: NMMailConfig
    
    // 标记是否是当前活跃账号
    var isCurrent: Bool
}

extension NMMailProtocolType: Codable {
}

extension NMMailConfig: Codable {
    
    enum CodingKeys: String, CodingKey {
        case email
        case host
        case port
        case ssl
        case username
        case password
        case protocolType
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(email, forKey: .email)
        try container.encode(host, forKey: .host)
        try container.encode(port, forKey: .port)
        try container.encode(ssl, forKey: .ssl)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(protocolType, forKey: .protocolType)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let email = try container.decode(String.self, forKey: .email)
        let host = try container.decode(String.self, forKey: .host)
        let port = try container.decode(Int.self, forKey: .port)
        let ssl = try container.decode(Bool.self, forKey: .ssl)
        let username = try container.decode(String.self, forKey: .username)
        
        // 处理可选值/默认值
        let password = try container.decodeIfPresent(String.self, forKey: .password) ?? ""
        let protocolType = try container.decodeIfPresent(NMMailProtocolType.self, forKey: .protocolType) ?? .imap
        
        self.init(
            email: email,
            host: host,
            port: port,
            ssl: ssl,
            username: username,
            password: password,
            protocolType: protocolType
        )
    }
}
