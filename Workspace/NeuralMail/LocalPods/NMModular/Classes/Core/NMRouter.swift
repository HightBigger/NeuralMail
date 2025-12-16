//
//  NMRouter.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import UIKit

// MARK: - 路由回调定义
/// 路由处理闭包：接收参数字典，返回一个 UIViewController
public typealias NMRouteHandler = (_ parameters: [String: String]) -> UIViewController?

public final class NMRouter {
    
    // 全局单例
    public static let shared = NMRouter()
    
    private init() {}
    
    // 存储路由表: Path -> Handler
    // e.g. "/chat/detail" -> Handler
    private var routes: [String: NMRouteHandler] = [:]
    
    // 线程锁
    private let lock = NSLock()
    
    // MARK: - 注册路由
    
    /// 注册一个路由路径
    /// - Parameters:
    ///   - pattern: 路由路径，例如 "chat/detail" (不需要 scheme)
    ///   - handler: 处理闭包，返回目标控制器
    public func register(path: String, handler: @escaping NMRouteHandler) {
        lock.lock()
        defer { lock.unlock() }
        
        // 简单规范化：确保以 / 开头
        let cleanPath = path.hasPrefix("/") ? path : "/" + path
        routes[cleanPath] = handler
    }
    
    // MARK: - 路由解析与跳转
    
    /// 获取符合 URL 的控制器实例 (不进行跳转)
    /// - Parameter urlString: 完整 URL，例如 "nm://chat/detail?id=123"
    /// - Returns: 匹配的 UIViewController，如果没有匹配则返回 nil
    public func match(url urlString: String) -> UIViewController? {
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("❌ [NMRouter] Invalid URL: \(urlString)")
            return nil
        }
        
        let path = components.path
        
        lock.lock()
        let handler = routes[path]
        lock.unlock()
        
        guard let routeHandler = handler else {
            print("⚠️ [NMRouter] No handler found for path: \(path)")
            return nil
        }
        
        // 解析参数
        var parameters: [String: String] = [:]
        components.queryItems?.forEach { item in
            parameters[item.name] = item.value ?? ""
        }
        
        return routeHandler(parameters)
    }
    
    /// 快捷跳转方法 (查找当前顶层 VC 并 Push)
    /// - Parameter url: 目标 URL
    public func push(to url: String, animated: Bool = true) {
        guard let targetVC = match(url: url) else { return }
        
        // 这是一个简化的导航查找逻辑，实际项目中可能需要更复杂的 Window/Tab 查找逻辑
        if let topVC = UIViewController.nm_topMostViewController() {
            if let nav = topVC as? UINavigationController {
                nav.pushViewController(targetVC, animated: animated)
            } else if let nav = topVC.navigationController {
                nav.pushViewController(targetVC, animated: animated)
            } else {
                // 如果没有导航栈，则 Present
                topVC.present(targetVC, animated: animated, completion: nil)
            }
        }
    }
}

// MARK: - 辅助扩展：查找顶层控制器
private extension UIViewController {
    static func nm_topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
            
        if let nav = base as? UINavigationController {
            return nm_topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return nm_topMostViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return nm_topMostViewController(base: presented)
        }
        return base
    }
}
