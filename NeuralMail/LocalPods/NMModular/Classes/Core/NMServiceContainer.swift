//
//  NMServiceContainer.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

// MARK: - 1. 服务作用域
public enum NMServiceScope {
    /// 单例：容器持有实例，App 生命周期内只创建一次
    case singleton
    /// 弱引用：容器不强持有实例。只要外部有对象持有它，它就存在；否则被释放。
    /// 适合 ViewController 或有循环引用风险的场景
    case weak
    /// 瞬态：每次 resolve 都会创建一个全新的实例
    case transient
}

// MARK: - 2. 服务注册接口
public protocol NMServiceRegistry {
    /// 注册服务
    /// - Parameters:
    ///   - service: 服务接口类型 (e.g. NMAuthService.self)
    ///   - scope: 生命周期作用域 (默认为 .singleton)
    ///   - factory: 创建实例的工厂闭包
    func register<Service>(_ service: Service.Type, scope: NMServiceScope, factory: @escaping () -> Service)
    
    /// 获取服务
    /// - Returns: 服务实例，如果未注册则返回 nil
    func resolve<Service>(_ service: Service.Type) -> Service?
    
    /// 卸载服务 (通常用于测试或重置)
    func unregister<Service>(_ service: Service.Type)
}

// 扩展方便使用默认参数
public extension NMServiceRegistry {
    func register<Service>(_ service: Service.Type, factory: @escaping () -> Service) {
        register(service, scope: .singleton, factory: factory)
    }
}

// MARK: - 3. 容器核心实现
public final class NMServiceContainer: NMServiceRegistry {
    
    // 全局单例
    public static let shared = NMServiceContainer()
    
    private init() {}
    
    // 线程锁，保证并发安全
    private let lock = NSRecursiveLock()
    
    // 存储服务的字典
    private var services: [String: ServiceEntry] = [:]
    
    // MARK: - 内部存储结构
    private class ServiceEntry {
        let scope: NMServiceScope
        let factory: () -> Any
        var strongInstance: Any?          // 用于 Singleton
        weak var weakInstance: AnyObject? // 用于 Weak
        
        init(scope: NMServiceScope, factory: @escaping () -> Any) {
            self.scope = scope
            self.factory = factory
        }
    }
    
    // MARK: - API 实现
    
    public func register<Service>(_ service: Service.Type, scope: NMServiceScope, factory: @escaping () -> Service) {
        let key = String(describing: service)
        let entry = ServiceEntry(scope: scope, factory: factory)
        
        lock.lock()
        services[key] = entry
        lock.unlock()
    }
    
    public func resolve<Service>(_ service: Service.Type) -> Service? {
        let key = String(describing: service)
        
        lock.lock()
        defer { lock.unlock() }
        
        guard let entry = services[key] else { return nil }
        
        switch entry.scope {
        case .singleton:
            if let instance = entry.strongInstance as? Service {
                return instance
            }
            let newInstance = entry.factory() as! Service
            entry.strongInstance = newInstance
            return newInstance
            
        case .weak:
            if let instance = entry.weakInstance as? Service {
                return instance
            }
            let newInstance = entry.factory() as! Service
            
            // 注意：Weak Scope 要求对象必须是引用类型 (AnyObject)
            // 如果是 Struct，这里无法 weak 引用，会降级为瞬态或导致 Crash
            if let object = newInstance as? AnyObject {
                entry.weakInstance = object
            } else {
                 print("⚠️ [NMServiceContainer] Warning: Weak scope requires reference type (Class). \(Service.self) is value type.")
            }
            return newInstance
            
        case .transient:
            return entry.factory() as? Service
        }
    }
    
    public func unregister<Service>(_ service: Service.Type) {
        let key = String(describing: service)
        lock.lock()
        services.removeValue(forKey: key)
        lock.unlock()
    }
}
