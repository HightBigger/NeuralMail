//
//  NMLogServerice.swift
//  NMLog
//
//  Created by 小大 on 2025/12/11.
//

import UIKit

public class NMLogServerice {
    
    public static let shared = NMLogServerice()
    
    public init() {}
    
    /// 由于日志记录可以是异步的，所以有时可能需要刷新日志。当应用程序退出时，框架会自动调用。
    public func flushLog() {
        NMLog.flushLog()
    }
    
    public func getLogDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/NMLog")
        return path
    }
    
}

public func NMLogInfo(_ message: String,
                    tag: String = "Neural",
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    NMLogBridge.logInfo(withTag: tag, file: fileName, function: function, line: Int32(line), message: message)
    
}

public func NMLogIError(_ message: String,
                      tag: String = "Neural",
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    NMLogBridge.logError(withTag: tag, file: fileName, function: function, line: Int32(line), message: message)
    
}

public func NMLogWraning(_ message: String,
                       tag: String = "Neural",
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    NMLogBridge.logWran(withTag: tag, file: fileName, function: function, line: Int32(line), message: message)
}

public func NMLogDebug(_ message: String,
                     tag: String = "Neural",
                      file: String = #file,
                      function: String = #function,
                      line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    NMLogBridge.logDebug(withTag: tag, file: fileName, function: function, line: Int32(line), message: message)
}
