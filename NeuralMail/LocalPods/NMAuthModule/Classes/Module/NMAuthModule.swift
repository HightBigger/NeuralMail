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

        registry.register(NMAccountRepository.self, scope: .singleton) {
            NMAccountRepository()
        }
        
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
       
    }
    
    public func start(context: NMLaunchContext) async {
        
      
        
        if let netService = NMServiceContainer.shared.resolve(NMNetworkService.self) {
            netService.register(interceptor: NMAuthInterceptor())
        }
    }
}
