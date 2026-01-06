//
//  NMMailFolderRepository.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/30.
//

import NMModular

class NMMailFolderRepository {
    
    @NMInjected private var dbService: NMDatabaseService
    @NMLogger("NMAuthModule") var logger
    
    /// 保存文件夹列表 (全量覆盖或更新)
    func saveFolders(_ folders: [NMMailFolder], forAccount accountId: String) async throws {
        
        for folder in folders {
            // 1. 转换为 Entity
            let entity = NMMailFolderEntity(
                accountId: accountId,
                path: folder.path,
                displayName: folder.displayName,
                delimiter: String(folder.delimiter),
                flags: folder.flags.rawValue
            )
            
            // 2. 调用接口层保存
            // 底层会自动执行 INSERT OR REPLACE
            try await dbService.save(entity)
        }
        
        logger.info("✅ [DB] 已保存 \(folders.count) 个文件夹")
    }
    
    /// 获取某账号下的所有文件夹
    func getFolders(forAccount accountId: String) async throws -> [NMMailFolder] {
        // 由于 NMDatabaseService 提供的 query 返回的是 [[String: Any]]
        // 或者 fetch 是按 id 查单个
        // 这里的 query 接口是“逃生舱”，用于执行自定义 SQL
   
        let sql = "SELECT * FROM mail_folders WHERE account_id = :account_id ORDER BY path ASC"
        let rows = try await dbService.query(sql: sql, arguments: ["account_id": accountId])
        
        // 手动将字典转回 Model (JSONDecoder 辅助)
        // 注意：因为 query 返回的是 [String: Any]，需要稍微处理一下解码
        let data = try JSONSerialization.data(withJSONObject: rows, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        let entities = try decoder.decode([NMMailFolderEntity].self, from: data)
        
        return entities.map{ $0.toDomain() }
    }
    
    /// 获取单个文件夹
    func getFolder(accountId: String, path: String) async throws -> NMMailFolderEntity? {
        let id = "\(accountId):\(path)"
        // 直接使用泛型 fetch
        return try await dbService.fetch(NMMailFolderEntity.self, id: id)
    }
}
