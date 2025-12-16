//
//  NMDatabaseService.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

// MARK: - 通用通知定义
public extension Notification.Name {
    /// 用户登录成功通知
    static let NMUserDidLogin = Notification.Name("NMUserDidLogin")
    /// 用户登出通知
    static let NMUserDidLogout = Notification.Name("NMUserDidLogout")
}

/// 认证服务协议
/// 职责：管理当前用户的登录状态、令牌和身份信息
public protocol NMAuthService {
    
    /// 当前是否已登录
    var isLoggedIn: Bool { get }
    
    /// 获取当前登录的用户信息 (内存缓存)
    /// 如果数据库读取尚未完成，可能暂时为 nil
    var currentUser: NMUser? { get }
    
    /// 获取当前的 Access Token (用于网络请求)
    var accessToken: String? { get }
    
    /// 执行登录
    /// - Parameters:
    ///   - email: 邮箱
    ///   - password: 密码
    func login(email: String, password: String) async throws
    
    /// 执行登出
    /// 包含网络通知和本地清理
    func logout() async
}
