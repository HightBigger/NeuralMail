//
//  NMAuthDTOs.swift
//  NMModular
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import NMModular // 引用 NMUser

/// 登录接口响应结构
/// JSON 示例: { "token": "abc...", "user": { "id": "1", ... } }
struct NMLoginResponse: Decodable {
    let token: String
    let user: NMUser
}

struct NMLogoutResponse: Decodable {
    let ret: Bool
}

// 如果有其他 API 响应结构，也可以定义在这里
// struct RegisterResponse: Decodable { ... }
