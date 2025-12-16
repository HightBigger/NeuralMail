//
//  NMNetworkService.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

public protocol NMNetworkService {
    /// 发送请求
    /// T: 返回的数据模型 (Decodable)
    func request<T: Decodable>(_ target: NMTargetType) async throws -> T
    
    /// 注册拦截器 (用于 Auth 模块注入 Token)
    func register(interceptor: NMNetworkInterceptor)
}

/// 拦截器协议
public protocol NMNetworkInterceptor {
    /// 发送前修改 Request (例如加 Token)
    func adapt(_ request: URLRequest) async -> URLRequest
}
