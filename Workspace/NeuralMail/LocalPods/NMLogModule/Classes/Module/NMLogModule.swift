import Foundation
import NMLog
import NMModular

public final class NMLogModule: NMModuleType {
    
    // 🔥 关键：日志必须是最高优先级！
    // 确保它在 Auth, Network 之前启动，否则其他模块启动报错时无法记录日志。
    public static var priority: NMModulePriority = .critical
        
    public init() {}
    
    // 1. 注册服务
    public func registerServices(registry: NMServiceRegistry) {
        // 注册为单例 (Singleton)
        registry.register(NMLogService.self, scope: .singleton) {
            return NMLogServiceImpl()
        }
    }
    
    // 2. 启动初始化
    public func start(context: NMLaunchContext) async {
        // 根据启动上下文配置日志核心
        // 例如：Debug 模式下输出到控制台，Release 模式下只写文件
        NMLogCore.shared.configure(isDebug: context.isDebug)
        
        // 打印第一条系统日志
        let logger = NMServiceContainer.shared.resolve(NMLogService.self)
        logger?.info("✅ NMLogModule started successfully.")
    }
    
    // 3. 处理系统事件
    public func applicationDidEnterBackground() {
        // 示例：进入后台时，强制将日志缓冲区写入磁盘
        let logger = NMServiceContainer.shared.resolve(NMLogService.self)
        logger?.info("App entering background, flushing logs...")
    }
}
