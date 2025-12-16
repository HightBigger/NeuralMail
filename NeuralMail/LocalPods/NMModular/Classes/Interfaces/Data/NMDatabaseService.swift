//
//  NMDatabaseService.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

public protocol NMDatabaseService {
    /// 注册迁移
    func register(migration: NMMigration)
    
    /// 建立连接
    func connect() async throws
    
    /// 泛型保存 (Insert or Replace)
    /// 业务层直接传 Model，不需要知道底层怎么存
    func save<T: NMPersistable>(_ item: T) async throws
    
    /// 泛型查询 (根据 ID)
    func fetch<T: NMPersistable>(_ type: T.Type, id: String) async throws -> T?
    
    /// 执行自定义 SQL (用于复杂查询，返回字典数组)
    /// 这是一个妥协接口，为了在不引入 ORM 的情况下支持复杂查询
    func query(sql: String, arguments: [String: Any]?) async throws -> [[String: Any]]
    
    /// 泛型删除
    func delete<T: NMPersistable>(_ type: T.Type, id: String) async throws
}
