//
//  NMMailClientService.swift
//  Alamofire
//
//  Created by 小大 on 2025/12/16.
//

import Foundation

public protocol NMMailClientService {
    /// 连接并验证账户
    func connect(config: NMMailConfig) async throws
    
    /// 获取文件夹列表
    func fetchFolders() async throws -> [NMMailFolder]
    
    /// 获取指定文件夹的邮件列表 (分页)
    /// - Parameters:
    ///   - folder: 文件夹路径 (e.g. "INBOX")
    ///   - offset: 起始位置 (0 based)
    ///   - limit: 数量
    func fetchMessages(folder: String, offset: Int, limit: Int) async throws -> [NMMailMessage]
    
    /// 断开连接
    func disconnect()
}
