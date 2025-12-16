//
//  NMInjected.swift
//  FDFullscreenPopGesture
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

/// 依赖注入属性包装器
@propertyWrapper
public struct NMInjected<Service> {
    
    private var service: Service?
    
    public init() {}
    
    public var wrappedValue: Service {
        mutating get {
            if service == nil {
                service = NMServiceContainer.shared.resolve(Service.self)
            }
            
            guard let s = service else {
                // 严重错误处理
                let errorMsg = "🛑 [NMInjected] Critical Error: Service <\(Service.self)> is not registered in NMServiceContainer!"
                
                #if DEBUG
                // 在开发环境下，直接崩溃以提醒开发者修复
                fatalError(errorMsg)
                #else
                // 生产环境下，打印错误日志 (甚至可以上传到 Crash 平台)，并尝试做降级处理
                // 注意：这里不得不返回一个强制解包的风险值，或者需要调用方处理 Optional
                // 为了保持调用方代码简洁，这里选择 FatalError 策略，意味着依赖缺失是不可接受的系统错误。
                print(errorMsg)
                fatalError(errorMsg)
                #endif
            }
            
            return s
        }
    }
}

/// 可选依赖注入属性包装器
/// 如果服务可能不存在，使用此包装器
/// 使用方法: @NMOptionalInjected var optionalService: NMOptionalService?
@propertyWrapper
public struct NMOptionalInjected<Service> {
    
    private var service: Service?
    private var resolved: Bool = false
    
    public init() {}
    
    public var wrappedValue: Service? {
        mutating get {
            if !resolved {
                service = NMServiceContainer.shared.resolve(Service.self)
                resolved = true
            }
            return service
        }
    }
}
