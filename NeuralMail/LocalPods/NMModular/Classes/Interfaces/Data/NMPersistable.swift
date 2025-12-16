//
//  NMPersistable.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

/// 持久化对象协议
/// 所有需要存储到数据库的业务模型 (Model) 都应遵守此协议
///
/// 设计原则：
/// 1. 继承 Codable：利用 Swift 原生能力进行序列化/反序列化，天然适配 GRDB、CoreData 或 JSON 文件。
/// 2. 继承 Identifiable：适配 SwiftUI 和列表 Diff 算法。
/// 3. 无 GRDB 依赖：保持 Core 层纯净。
public protocol NMPersistable: Codable, Identifiable {
    
    /// 数据库中的表名
    /// 例如: "emails", "contacts"
    static var databaseTableName: String { get }
}

// MARK: - 默认实现 (可选)
public extension NMPersistable {
    // 如果你希望默认表名就是类型名 (例如 struct User -> table "User")
    // 可以解开下面的注释，但通常建议显式指定全小写下划线风格 (e.g. "user_profile")
    /*
    static var databaseTableName: String {
        return String(describing: Self.self)
    }
    */
}
