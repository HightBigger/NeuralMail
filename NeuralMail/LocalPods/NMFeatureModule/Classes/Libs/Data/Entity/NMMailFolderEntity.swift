//
//  NMMailFolderEntity.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/30.
//

import Foundation
import NMModular // 依赖核心接口

/// 文件夹的数据库实体
/// 实现了 NMPersistable，可以直接被 NMDatabaseService 存储
public struct NMMailFolderEntity: NMPersistable {
    
    // MARK: - NMPersistable 配置
    
    /// 表名 (snake_case)
    public static var databaseTableName = "mail_folders"
    
    // MARK: - 属性
    
    /// 主键 (Primary Key)
    /// 策略：为了配合 fetch(id:) 接口，建议使用 "account_id:path" 的组合键
    /// 例如: "test@qq.com:INBOX"
    public var id: String
    
    /// 所属账号 (用于多账号隔离)
    public var accountId: String
    
    /// 文件夹路径 (IMAP 原始路径)
    public var path: String
    
    /// 显示名称
    public var displayName: String
    
    /// 分隔符 (存 String 方便数据库处理)
    public var delimiter: String
    
    /// 标记位 (Int)
    public var flags: Int
    
    /// 未读数
    public var unreadCount: Int
    
    /// 总数
    public var totalCount: Int
    
    /// 最后更新时间
    public var updatedAt: Date
    
    // MARK: - 映射关系 (Swift Property -> DB Column)
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id" // 映射为下划线风格
        case path
        case displayName = "display_name"
        case delimiter
        case flags
        case unreadCount = "unread_count"
        case totalCount = "total_count"
        case updatedAt = "updated_at"
    }
    
    // MARK: - 初始化
    
    public init(
        accountId: String,
        path: String,
        displayName: String,
        delimiter: String = "/",
        flags: Int = 0,
        unreadCount: Int = 0,
        totalCount: Int = 0
    ) {
        // 生成唯一 ID
        self.id = "\(accountId):\(path)"
        self.accountId = accountId
        self.path = path
        self.displayName = displayName
        self.delimiter = delimiter
        self.flags = flags
        self.unreadCount = unreadCount
        self.totalCount = totalCount
        self.updatedAt = Date()
    }
}

extension NMMailFolderEntity {
    /// 将数据库实体转换为业务模型
    /// 这里的 NMMailFolder 是定义在 NMModular 中的公开结构体
    func toDomain() -> NMMailFolder {

        return NMMailFolder(
            path: self.path,
            displayName: self.displayName,
            delimiter: Character(self.delimiter), 
            flags: self.flags
        )
    }
}
