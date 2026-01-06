//
//  NMAuthMigration.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/15.
//

import NMModular

struct NMAuthMigration: NMMigration {
    // 唯一标识符
    var identifier: String = "v1_create_user_profile"
    
    // ✅ 纯 SQL 建表语句
    var sql: String {
        """
        CREATE TABLE user_profile (
            id TEXT PRIMARY KEY NOT NULL,
            email TEXT NOT NULL,
            nickname TEXT,
            avatarURL TEXT
        );
        """
    }
}
