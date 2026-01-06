//
//  NMMailDetailViewModel.swift
//  NMFeatureModule
//
//  Created by 小大 on 2025/12/26.
//

import Foundation
import NMModular

public class NMMailDetailViewModel {
    
    // MARK: - Dependencies
    @NMInjected private var featureService: NMFeatureService
    @NMLogger("NMDetailVM") private var logger
    
    // MARK: - State
    @MainActor @Published var htmlContent: String = ""
    @MainActor @Published var message: NMMailMessage? // 详情头信息
    
    // MARK: - Actions
    
    /// 加载详情
    /// - Parameter id: 邮件 ID
    public func loadDetail(id: String) {
//        Task {
//            do {
//                let (msgDetail, html) = try await featureService.fetchMessageDetail(id: id)
//                
//                await MainActor.run {
//                    self.htmlContent = html
//                    // 如果 Service 返回了更详细的 Header，更新它
//                    if let detail = msgDetail {
//                        self.message = detail
//                    }
//                }
//            } catch {
//                logger.error("加载详情失败: \(error)")
//                // 实际项目中应通知 UI 显示错误页
//            }
//        }
    }
}
