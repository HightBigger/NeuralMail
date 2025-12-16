//
//  NMDataModule.swift
//  NMDataModule
//
//  Created by 小大 on 2025/12/12.
//

import NMModular

public final class NMDataModule: NMModuleType {
    
    // 数据库是关键基础设施，优先级设为 Critical
    public static var priority: NMModulePriority = .critical
    
    public init() {}
    
    public func registerServices(registry: NMServiceRegistry) {
        // ✅ 使用 NMDatabaseServiceImpl
        registry.register(NMDatabaseService.self, scope: .singleton) {
            NMDatabaseServiceImpl()
        }
    }
    
    public func start(context: NMLaunchContext) async {
        // 启动时尝试连接数据库
        if let service = NMServiceContainer.shared.resolve(NMDatabaseService.self) {
            do {
                try await service.connect()
            } catch {
                // 严重错误：建议上报 Crash 或进入安全模式
                print("❌ [NMDataModule] Database connect failed: \(error)")
            }
        }
    }
}
