//
//  NMDatabaseServiceImpl.swift
//  NMDataModule
//
//  Created by 小大 on 2025/12/12.
//

import Foundation
import NMModular
import GRDB // ✅ 全局唯一引用 GRDB 的地方

/// 数据库服务的具体实现
/// 负责将 Core 层的纯数据请求转换为 GRDB 的底层操作
final class NMDatabaseServiceImpl: NMDatabaseService {
    
    // 支持并发读写 (WAL 模式)
    private var dbWriter: DatabaseWriter?
    
    // 迁移脚本列表
    private var migrations: [NMMigration] = []
    
    // 线程锁
    private let lock = NSLock()
    
    // JSON 编码器 (用于将 Model 转为 DB 字典)
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .millisecondsSince1970 // 统一时间格式
        return e
    }()
    
    // JSON 解码器 (用于处理某些特殊 JSON 字段)
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .millisecondsSince1970
        return d
    }()
    
    public init() {}
    
    // MARK: - 1. 配置与连接
    
    func register(migration: NMMigration) {
        lock.lock()
        defer { lock.unlock() }
        migrations.append(migration)
    }
    
    func connect() async throws {
        guard dbWriter == nil else { return }
        
        // 1. 路径配置
        let databaseURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("NeuralMail.sqlite")
            
        // 2. GRDB 配置
        var config = Configuration()
        config.prepareDatabase { db in
            // 开启外键约束等 SQLite 最佳实践
            try db.execute(sql: "PRAGMA foreign_keys = ON")
        }
        
        // 3. 创建连接池 (DatabasePool 默认开启 WAL)
        let pool = try DatabasePool(path: databaseURL.path, configuration: config)
        
        // 4. 执行迁移
        try performMigrations(on: pool)
        
        self.dbWriter = pool
        print("🗄 [NMDatabaseServiceImpl] Connected: \(databaseURL.path)")
    }
    
    // MARK: - 2. 泛型 CRUD 实现 (核心桥接)
    
    func save<T: NMPersistable>(_ item: T) async throws {
        guard let writer = dbWriter else { throw makeError("DB not connected") }
        
        // 1. 将 Codable 对象转为字典 [String: Any]
        let dictionary = try item.toDictionary(encoder: self.encoder)
        guard !dictionary.isEmpty else { return }
        
        // 2. 动态构建 SQL
        // INSERT OR REPLACE INTO table (col1, col2) VALUES (?, ?)
        let tableName = T.databaseTableName
        let columns = dictionary.keys.sorted() // 排序保证顺序一致
        let values = columns.compactMap { dictionary[$0] }
        
        let columnString = columns.joined(separator: ", ")
        let placeholders = Array(repeating: "?", count: columns.count).joined(separator: ", ")
        let sql = "INSERT OR REPLACE INTO \(tableName) (\(columnString)) VALUES (\(placeholders))"
        
        // 3. 执行写入
        try await writer.write { db in
            // GRDB 支持传入数组作为 arguments
            let dbValues = values.map { $0 as? DatabaseValueConvertible }
            try db.execute(sql: sql, arguments: StatementArguments(dbValues))
        }
    }
    
    func fetch<T: NMPersistable>(_ type: T.Type, id: String) async throws -> T? {
        guard let writer = dbWriter else { throw makeError("DB not connected") }
        
        let sql = "SELECT * FROM \(T.databaseTableName) WHERE id = ? LIMIT 1"
        
        return try await writer.read { db in
            // GRDB Magic: Row 遵循 Decoder 协议
            // 所以我们可以用 T(from: row) 直接解码 Codable 对象
            let args = StatementArguments([id])
            if let row = try Row.fetchOne(db, sql: sql, arguments: args) {
                return try T(from: row as! Decoder)
            }
            return nil
        }
    }
    
    func delete<T: NMPersistable>(_ type: T.Type, id: String) async throws {
        guard let writer = dbWriter else { throw makeError("DB not connected") }
        
        let sql = "DELETE FROM \(T.databaseTableName) WHERE id = ?"
        
        try await writer.write { db in
            try db.execute(sql: sql, arguments: [id])
        }
    }
    
    func query(sql: String, arguments: [String : Any]?) async throws -> [[String : Any]] {
        guard let writer = dbWriter else { throw makeError("DB not connected") }
        
        return try await writer.read { db in
            
            // ✅ 修复步骤 1: 准备 StatementArguments
            // StatementArguments 不接受 [String: Any]，必须手动转换为 [String: DatabaseValueConvertible?]
            var stmtArgs = StatementArguments()
            
            if let args = arguments {
                // 使用 mapValues 将 Any 转换为 DatabaseValueConvertible
                let mappedArgs = args.mapValues { $0 as? DatabaseValueConvertible }
                stmtArgs = StatementArguments(mappedArgs)
            }
            
            // ✅ 修复步骤 2: 传入构建好的 stmtArgs (它是非可选的 StatementArguments 类型)
            let rows = try Row.fetchAll(db, sql: sql, arguments: stmtArgs)
            
            // ✅ 修复步骤 3: 结果转换 Row -> [String: Any]
            return rows.map { row in
                row.reduce(into: [String: Any]()) { dict, pair in
                    dict[pair.0] = pair.1.storage.value
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func performMigrations(on writer: DatabaseWriter) throws {
        var migrator = DatabaseMigrator()
        
        // 禁用外键检查以允许表结构变更
        migrator.registerMigration("disable_foreign_keys") { db in
            try db.execute(sql: "PRAGMA foreign_keys = OFF")
        }
        
        for migration in migrations {
            migrator.registerMigration(migration.identifier) { db in
                // 直接执行业务模块传来的纯 SQL 字符串
                try db.execute(sql: migration.sql)
            }
        }
        
        try migrator.migrate(writer)
    }
    
    private func makeError(_ msg: String) -> NSError {
        return NSError(domain: "NMDatabaseServiceImpl", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}

// MARK: - 辅助扩展：Codable -> Dictionary

private extension Encodable {
    func toDictionary(encoder: JSONEncoder) throws -> [String: Any] {
        let data = try encoder.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert model to dictionary"])
        }
        return dictionary
    }
}
