//
//  NMAuthModule.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/10.
//

import NMModular

public final class NMMailModule: NMModuleType {
    
    public static var priority: NMModulePriority = .normal
    
    public init() {}
    
    public func registerServices(registry: NMServiceRegistry) {
        // 注册邮件客户端服务
        registry.register(NMMailService.self, scope: .singleton) {
            NMMailServiceImpl()
        }
    }
    
    public func start(context: NMLaunchContext) async {
        print("📧 [NMMailModule] MailCore wrapper ready.")
    }
}
