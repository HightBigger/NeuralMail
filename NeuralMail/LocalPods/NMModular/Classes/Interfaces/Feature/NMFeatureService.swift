//
//  NMFeatureService.swift
//  NMFeatureModule
//
//  Created by 小大 on 2025/12/25.
//

import Foundation

/// 邮件主页业务服务协议
/// 命名规范: NM + 业务名 + Service
public protocol NMFeatureService {
    
    /// 拉取收件箱最新邮件
    /// - Parameters:
    ///   - folder: path
    ///   - limit: 拉取数量
    ///   - offset: 分页偏移量
    /// - Returns: [NMMailMessage] (使用核心模块定义的通用模型)
    func fetchLatestMessages(folder: String, limit: Int, offset: Int) async throws -> [NMMailMessage]
    
    /// 获取侧边栏文件夹列表
    func fetchSideBarFolders() async throws -> [NMMailFolder]
    
    /// 搜索邮件
    func searchMessages(keyword: String) async throws -> [NMMailMessage]
}
