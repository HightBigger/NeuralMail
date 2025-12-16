//
//  NMMigration.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

public protocol NMMigration {
    /// 唯一标识
    var identifier: String { get }
    
    /// 原始 SQL 建表语句
    /// 业务模块只需要写 String，不需要 import GRDB
    var sql: String { get }
}
