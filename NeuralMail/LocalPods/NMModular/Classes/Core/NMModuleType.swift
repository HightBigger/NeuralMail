//
//  NMModuleType.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//


import UIKit

// MARK: - 1. 启动上下文
/// 用于在 App 启动时传递必要的环境参数
public struct NMLaunchContext {
    public let launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    public let isDebug: Bool
    
    public init(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, isDebug: Bool = false) {
        self.launchOptions = launchOptions
        self.isDebug = isDebug
    }
}

// MARK: - 2. 模块优先级
/// 定义模块的启动优先级，数字越大越早启动
public enum NMModulePriority: Int {
    case critical = 1000  // 崩溃监控、日志、配置中心 (阻塞主线程，立即执行)
    case high = 750       // 核心业务基础 (如：网络栈、数据库、认证状态)
    case normal = 500     // 普通业务模块 (UI 初始化等)
    case low = 100        // 非核心功能 (后台预加载、埋点上传)
}

// MARK: - 3. 模块协议
/// 所有 NM 业务模块必须遵循的协议
public protocol NMModuleType: AnyObject {
    
    /// 模块优先级 (默认为 .normal)
    static var priority: NMModulePriority { get }
    
    /// 注册服务
    /// 在此方法中进行依赖注入的注册 (NMServiceRegistry.register)
    /// 注意：不要在此处进行耗时操作或 resolve 其他服务
    func registerServices(registry: NMServiceRegistry)
    
    /// 模块启动
    /// 在此方法中进行模块的初始化逻辑 (如 SDK 初始化、数据库连接)
    /// 支持 async/await
    func start(context: NMLaunchContext) async
    
    // MARK: - 生命周期钩子 (Optional)
    
    /// 用户登录成功
    func userDidLogin(userId: String)
    
    /// 用户登出 (用于清理敏感数据、断开连接)
    func userDidLogout()
    
    /// App 进入后台
    func applicationDidEnterBackground()
    
    /// App 收到内存警告
    func applicationDidReceiveMemoryWarning()
}

// MARK: - 默认实现
/// 让模块只需实现自己关心的生命周期方法
public extension NMModuleType {
    static var priority: NMModulePriority { .normal }
    
    func registerServices(registry: NMServiceRegistry) {}
    func start(context: NMLaunchContext) async {}
    
    func userDidLogin(userId: String) {}
    func userDidLogout() {}
    func applicationDidEnterBackground() {}
    func applicationDidReceiveMemoryWarning() {}
}
