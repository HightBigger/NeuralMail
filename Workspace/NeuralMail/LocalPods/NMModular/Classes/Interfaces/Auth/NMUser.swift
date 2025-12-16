//
//  NMUser.swift
//  NMModular
//
//  Created by 小大 on 2025/12/15.
//

import Foundation

/// 全局用户模型
/// 遵循 NMPersistable (Codable + Identifiable)，可直接存入数据库
public struct NMUser: NMPersistable {
    
    /// 数据库表名
    public static var databaseTableName: String { "user_profile" }
    
    public let id: String
    public let email: String
    public let nickname: String?
    public let avatarURL: String?
    
    public init(id: String, email: String, nickname: String? = nil, avatarURL: String? = nil) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.avatarURL = avatarURL
    }
}
