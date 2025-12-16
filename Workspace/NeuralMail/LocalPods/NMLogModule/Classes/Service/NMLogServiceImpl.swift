//
//  NMLogServiceImpl.swift
//  NMLogModule
//
//  Created by 小大 on 2025/12/12.
//

import Foundation
import NMLog
import NMModular

/// 日志服务的具体实现适配器
final class NMLogServiceImpl: NMLogService {
    
    func info(_ message: String, tag: String, file: String, function: String, line: Int) {
        NMLogBridge.logInfo(withTag: tag, file: file, function: function, line: Int32(line), message: message)
    }
    
    func debug(_ message: String, tag: String,file: String, function: String, line: Int) {
        NMLogBridge.logDebug(withTag: tag, file: file, function: function, line: Int32(line), message: message)
    }
    
    func warn(_ message: String, tag: String,file: String, function: String, line: Int) {
        NMLogBridge.logWran(withTag: tag, file: file, function: function, line: Int32(line), message: message)
    }
    
    func error(_ message: String, tag: String,file: String, function: String, line: Int) {
        NMLogBridge.logError(withTag: tag, file: file, function: function, line: Int32(line), message: message)
    }

}
