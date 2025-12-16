//
//  NMAuthModule.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/10.
//


import NMModular

public final class NMAuthModule: NMModuleType {
    
    // 认证是核心业务，优先级高 (High)
    public static var priority: NMModulePriority = .high
    
    public init() {}
    
    public func registerServices(registry: NMServiceRegistry) {
        // 1. 注册 Service
        registry.register(NMAuthService.self, scope: .singleton) {
            NMAuthServiceImpl()
        }
        
        // 2. 注册数据库迁移 (Core/Database)
        if let dbService = registry.resolve(NMDatabaseService.self) {
            dbService.register(migration: NMAuthMigration())
        }
        
        // 注册路由 nm://auth/login
        NMRouter.shared.register(path: "/auth/login") { parameters in
            // params 是 [String: String] 字典
            let email = parameters["email"]
            
            let loginVC = NMLoginViewController(defaultEmail: email )
            return loginVC
        }
        
        // 注册注册页路由: nm://auth/register
        NMRouter.shared.register(path: "/auth/register") { _ in
            let loginVC = NMRegisterViewController()
            return loginVC
        }
    }
    
    public func start(context: NMLaunchContext) async {
        // 3. 注入网络拦截器 (Core/Network)
        if let netService = NMServiceContainer.shared.resolve(NMNetworkService.self) {
            netService.register(interceptor: NMAuthInterceptor())
        }
        
        // 可以在这里做一些简单的 Token 预检
        print("🔐 [NMAuthModule] Ready.")
    }
}
