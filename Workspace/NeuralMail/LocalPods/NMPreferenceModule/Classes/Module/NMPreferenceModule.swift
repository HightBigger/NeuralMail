//
//  NMAuthModule.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/10.
//


import NMModular

public final class NMPreferenceModule: NMModuleType {
    
    // 设置为 High，确保在 LoginVC 展示前，语言和主题已就绪
    public static var priority: NMModulePriority = .high
    
    public init() {}
    
    public func registerServices(registry: NMServiceRegistry) {
        registry.register(NMPreferenceService.self, scope: .singleton) {
            NMPreferenceServiceImpl()
        }
        
        NMRouter.shared.register(path: "/preference/language") { _ in
            return NMLanguageSelectionViewController()
        }
        // ...
    }
    
    public func start(context: NMLaunchContext) async {
        // ✅ 模块启动时立即应用偏好 (如主题色)
        if let service = NMServiceContainer.shared.resolve(NMPreferenceService.self) {
            service.applyConfiguration()
        }
    }
}
