//
//  NMLogger.swift
//  NMModular
//
//  Created by 小大 on 2025/12/15.
//

import Foundation

/// 日志记录器代理 (Logger Proxy)
/// 它持有模块名，负责转发调用给 NMLogService
public struct NMModuleLogger {
    private let moduleName: String
    private var service: NMLogService? {
        // 动态获取服务，避免持有无效引用
        return NMServiceContainer.shared.resolve(NMLogService.self)
    }
    
    public init(moduleName: String) {
        self.moduleName = moduleName
    }

    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        service?.debug(message, tag: moduleName, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        service?.info(message, tag: moduleName, file: file, function: function, line: line)
    }
    
    public func warn(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        service?.warn(message, tag: moduleName, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        service?.error(message, tag: moduleName, file: file, function: function, line: line)
    }
}

// MARK: - 属性包装器 (推荐用法)

/// 自动注入并绑定模块名的日志属性包装器
/// 使用: @NMLogger("Auth") var logger
@propertyWrapper
public struct NMLogger {
    
    private let logger: NMModuleLogger
    
    public init(_ moduleName: String) {
        self.logger = NMModuleLogger(moduleName: moduleName)
    }
    
    public var wrappedValue: NMModuleLogger {
        return logger
    }
}
