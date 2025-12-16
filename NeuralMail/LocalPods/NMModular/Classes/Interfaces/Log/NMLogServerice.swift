//
//  NMLogServerice.swift
//  NMLog
//
//  Created by 小大 on 2025/12/11.
//

import Foundation

/// 核心日志方法
/// - Parameters:
///   - tag: 模块名称 (新增)
///   - message: 内容
///   - file/function/line: 调试信息
public protocol NMLogService {
    func debug(_ message: String, tag: String,file: String, function: String, line: Int)
    func info(_ message: String, tag: String,file: String, function: String, line: Int)
    func warn(_ message: String, tag: String,file: String, function: String, line: Int)
    func error(_ message: String, tag: String,file: String, function: String, line: Int)
}

public extension NMLogService {
    func debug(_ message: String,tag: String = "NeuralMail", file: String = #file, function: String = #function, line: Int = #line) {
        debug(message, tag: tag, file: file, function: function, line: line)
    }
    
    func info(_ message: String,tag: String = "NeuralMail", file: String = #file, function: String = #function, line: Int = #line) {
        info(message, tag: tag, file: file, function: function, line: line)
    }
    
    func warn(_ message: String,tag: String = "NeuralMail", file: String = #file, function: String = #function, line: Int = #line) {
        warn(message, tag: tag, file: file, function: function, line: line)
    }
    
    func error(_ message: String,tag: String = "NeuralMail", file: String = #file, function: String = #function, line: Int = #line) {
        error(message, tag: tag, file: file, function: function, line: line)
    }
}

