//
//  NMMailFolderMigration.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/30.
//

import NMModular

public struct NMMailFolderMigration: NMMigration {
    
    public var identifier: String = "create_mail_folders_table_v1"
    
    public var sql: String = """
    CREATE TABLE IF NOT EXISTS mail_folders (
        -- 1. 主键: 必须叫 id (配合 fetch 接口), 类型 TEXT
        id TEXT PRIMARY KEY NOT NULL,
        
        -- 2. 业务字段 (必须与 CodingKeys 一致)
        account_id TEXT NOT NULL,
        path TEXT NOT NULL,
        display_name TEXT,
        delimiter TEXT,
        flags INTEGER DEFAULT 0,
        unread_count INTEGER DEFAULT 0,
        total_count INTEGER DEFAULT 0,
        updated_at REAL, -- 存时间戳
        
        -- 3. 约束: 同一个账号下路径唯一 (其实被 ID 主键覆盖了，但为了保险可加)
        UNIQUE(account_id, path)
    );
    
    -- 4. 索引: 加速按账号查询列表
    CREATE INDEX IF NOT EXISTS idx_mail_folders_account ON mail_folders (account_id);
    """
    
    public init() {}
}
