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
    
    /// 数据库中的表名
    public static var databaseTableName: String { "user_profile" }
    
    // MARK: - Core Properties
    
    /// 用户唯一标识符 (通常由后端生成，或者是邮箱的哈希值)
    public let id: String
    
    /// 邮箱地址 (作为核心账号凭证)
    public let email: String
    
    /// 用户昵称 (可选，如果未设置则 UI 层通常显示邮箱前缀)
    public var nickname: String?
    
    /// 头像 URL (可选)
    public var avatarUrl: URL?
    
    /// 会员状态 (AI 邮件客户端通常有高级功能限制)
    public var isVip: Bool
    
    /// 注册/创建时间
    public let createdAt: Date
    
    /// 个性化签名 (邮件末尾的 Signature)
    public var signature: String?
    
    // MARK: - Initializer
    
    public init(id: String = UUID().uuidString,
                email: String,
                nickname: String? = nil,
                avatarUrl: URL? = nil,
                isVip: Bool = false,
                createdAt: Date = Date(),
                signature: String? = nil) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.avatarUrl = avatarUrl
        self.isVip = isVip
        self.createdAt = createdAt
        self.signature = signature
    }
}

// MARK: - Computed Properties (Helpers)

extension NMUser {
    
    /// UI 显示名称
    /// 逻辑：优先显示昵称，没有昵称显示邮箱前缀，都没有显示完整邮箱
    public var displayName: String {
        if let name = nickname, !name.isEmpty {
            return name
        }
        // 尝试截取邮箱 @ 前面的部分
        let components = email.components(separatedBy: "@")
        if let prefix = components.first, !prefix.isEmpty {
            return prefix
        }
        return email
    }
    
    /// 头像占位文字 (用于未加载头像时显示，如 "JD")
    public var initials: String {
        let name = displayName
        // 取前两个字符并大写
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Mock Data (For Testing/Preview)

#if DEBUG
extension NMUser {
    /// 测试用数据
    public static let mockUser = NMUser(
        id: "user_001",
        email: "alice@example.com",
        nickname: "Alice AI",
        avatarUrl: URL(string: "https://i.pravatar.cc/300"),
        isVip: true,
        signature: "Sent from my AI Mail App"
    )
    
    public static let mockFreeUser = NMUser(
        id: "user_002",
        email: "bob@test.com",
        nickname: nil,
        isVip: false
    )
}
#endif
