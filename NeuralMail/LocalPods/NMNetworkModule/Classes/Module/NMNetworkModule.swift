//
//  NMNetworkModule.swift
//  NMNetworkModule
//
//  Created by 小大 on 2025/12/12.
//

import NMModular

public final class NMNetworkModule: NMModuleType {
    
    // 网络层优先级较高，需要在业务模块之前准备好
    public static var priority: NMModulePriority = .high
    
    // 自动注入日志服务
    @NMLogger("NMNetworkModule") var logger
    
    public init() {}
    
    public func registerServices(registry: NMServiceRegistry) {
        // 1. 注册网络服务 (单例)
        registry.register(NMNetworkService.self, scope: .singleton) {
            NMNetworkServiceImpl()
        }
    }
    
    public func start(context: NMLaunchContext) async {
        guard let service = NMServiceContainer.shared.resolve(NMNetworkService.self) as? NMNetworkServiceImpl else { return }
        
        // 2. 配置环境参数 (Debug/Release)
        service.configureEnvironment(isDebug: context.isDebug)
        
        // 3. 配置 User-Agent (利用 context 中的信息或 Bundle 信息)
        let userAgent = generateUserAgent()
        service.updateCommonHeader(key: "User-Agent", value: userAgent)
        service.updateCommonHeader(key: "X-App-Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
        
        // 4. 启动网络监听
        service.startReachabilityMonitoring()
        
        logger.info("🌐 [NMNetworkModule] Initialized. UserAgent: \(userAgent)")
    }
    
    // 辅助方法：生成标准 User-Agent
    private func generateUserAgent() -> String {
        let executable = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "NeuralMail"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let device = UIDevice.current
        let osName = device.systemName // e.g. "iOS"
        let osVersion = device.systemVersion // e.g. "15.4"
        return "\(executable)/\(appVersion) (\(osName); \(osVersion); \(device.model))"
    }
}
