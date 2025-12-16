//
//  NMModuleManager.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

public final class NMModuleManager {
    
    // 全局单例
    public static let shared = NMModuleManager()
    
    private init() {}
    
    // 持有所有已注册的模块
    private var modules: [NMModuleType] = []
    
    // 标记是否已启动，防止重复启动
    private var isStarted: Bool = false
    
    // 使用 @MainActor 保证 UI 线程读取安全
    @MainActor public private(set) var isReady: Bool = false
    
    // MARK: - 注册管理
    
    /// 注册单个模块
    public func register(module: NMModuleType) {
        modules.append(module)
    }
    
    /// 批量注册模块
    public func register(modules: [NMModuleType]) {
        self.modules.append(contentsOf: modules)
    }
    
    // MARK: - 启动流程 (核心)
    
    /// 启动所有模块
    /// 1. 按优先级排序
    /// 2. 注册服务 (同步)
    /// 3. 执行启动逻辑 (异步)
    public func startup(context: NMLaunchContext) async {
        guard !isStarted else { return }
        isStarted = true
        
        // 1. 根据优先级降序排序 (Critical -> High -> Normal -> Low)
        let sortedModules = modules.sorted {
                    type(of: $0).priority.rawValue > type(of: $1).priority.rawValue
                }
        
        // 更新排序后的列表，用于后续事件分发
        self.modules = sortedModules
        
        print("🚀 [NMModuleManager] Starting \(modules.count) modules...")
        
        // 2. 第一阶段：服务注册 (Register Services)
        // 这是一个同步过程，必须非常快，不能有耗时操作
        for module in sortedModules {
            module.registerServices(registry: NMServiceContainer.shared)
        }
        
        // 3. 第二阶段：模块初始化 (Start)
        // 按照优先级顺序执行异步启动
        // 对于 Critical/High 模块，我们可能希望串行等待；对于 Low 模块，可以并行
        for module in sortedModules {
            let moduleName = String(describing: type(of: module))
            
            // 如果是 Critical 模块，我们强制 await 等待它完成，因为它可能阻塞后续流程
            if type(of: module).priority == .critical {
                await module.start(context: context)
                print("✅ [NMModuleManager] Critical module started: \(moduleName)")
            } else {
                // 非 Critical 模块，可以选择并行启动以加快速度
                Task {
                    await module.start(context: context)
                    if context.isDebug {
                        print("✅ [NMModuleManager] Module started: \(moduleName)")
                    }
                }
            }
        }
        
        await MainActor.run {
            self.isReady = true
            // 可选：发送一个通知，不仅支持轮询，也支持通知模式
            NotificationCenter.default.post(name: .NMAppDidFinishStartup, object: nil)
        }
    }
    
    // MARK: - 生命周期事件分发
    
    public func userDidLogin(userId: String) {
        modules.forEach { $0.userDidLogin(userId: userId) }
    }
    
    public func userDidLogout() {
        modules.forEach { $0.userDidLogout() }
    }
    
    public func applicationDidEnterBackground() {
        modules.forEach { $0.applicationDidEnterBackground() }
    }
    
    public func applicationDidReceiveMemoryWarning() {
        modules.forEach { $0.applicationDidReceiveMemoryWarning() }
    }
}

// 扩展 Notification 定义
extension Notification.Name {
    static let NMAppDidFinishStartup = Notification.Name("NMAppDidFinishStartup")
}
