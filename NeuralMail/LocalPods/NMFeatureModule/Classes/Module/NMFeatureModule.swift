//
//  NMFeatureModule.swift
//  NMFeatureModule
//
//  Created by 小大 on 2025/12/25.
//

import Foundation
import NMModular

/// 业务功能模块 (Feature Layer)
public class NMFeatureModule: NMModuleType {
    
    // MARK: - Config
    
    // 业务模块优先级通常为 Normal，晚于 High (网络/数据库) 启动
    public static var priority: NMModulePriority = .normal
    
    public init() {}
    
    // MARK: - Service Registration
    
    public func registerServices(registry: NMServiceRegistry) {
        // Scope 选择 .singleton (单例) 或 .transient (每次创建)
        // 这里建议单例，因为 ServiceImpl 内部无状态，且持有 Injected 属性
        registry.register(NMFeatureService.self, scope: .singleton) {
            NMFeatureServiceImpl()
        }
        
        registry.register(NMMailFolderRepository.self, scope: .singleton) {
            NMMailFolderRepository()
        }
        
        if let dbService = registry.resolve(NMDatabaseService.self) {
            dbService.register(migration: NMMailFolderMigration())
        }
        
        // 如果有其他业务服务 (比如 NMSettingsService)，也在这里注册
    }
    
    // MARK: - Lifecycle
    
    public func start(context: NMLaunchContext) async {
        // 模块启动逻辑
        if context.isDebug {
            print("✨ [NMFeatureModule] Feature Module Started")
        }
        
        // 可以在这里注册路由 (如果有 UI 跳转需求)
        registerRoutes()
    }
    
    // MARK: - Route Registration
    
    private func registerRoutes() {
        // 注册路由：nm://mail/home
        NMRouter.shared.register(path: "/mail/home") { params in
            
            return NMMailHomeViewController()
        }
        
        // 格式: nm://mail/detail?id=123&subject=Hello
        NMRouter.shared.register(path: "/mail/detail") { params in
            guard let id = params["id"] else { return nil }
            
            let vc = NMMailDetailViewController(messageId: id)
            
            // 可选：如果是从列表跳过来的，可以先设置标题占位，优化体验
            if let subject = params["subject"]?.removingPercentEncoding {
                vc.title = subject
                 vc.updateHeader(subject: subject)
            }

            return vc
        }
        
    }
    
    // MARK: - User Context
    
    public func userDidLogin(userId: String) {
        print("👤 [NMFeatureModule] User logged in: \(userId)")
        // 可以在这里触发一次预加载
    }
    
    public func userDidLogout() {
        print("👋 [NMFeatureModule] Cleaning up user data...")
    }
}
