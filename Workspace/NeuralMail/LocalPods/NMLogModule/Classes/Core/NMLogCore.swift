//
//  NMLogCore.swift
//  NMLogModule
//
//  Created by 小大 on 2025/12/12.
//

import UIKit
import NMLog

// 假设这是你已经开发完成的日志核心类 (The "Existing" Logic)
// 实际项目中，这可能是 import CocoaLumberjack 或 import XCGLogger
final class NMLogCore {
    static let shared = NMLogCore()
    
    func configure(isDebug: Bool) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/NMLog")
        
        print("Logpath:\(path)")
        // 启用控制台输出
        NMLog.setLogConsole(isDebug)
        
        // 设置日志文件大小上限为10MB
        NMLog.setLogMaxFileSize(10 * 1024 * 1024)
        
        // 设置日志文件最大数量为50个
        NMLog.setLogMaxNumLogFiles(50)
        
        NMLog.setLogRollingFrequency(60 * 60 * 12)
        
        // 设置日志占用磁盘总大小为50MB
        NMLog.setLogFilesDiskQuota(50 * 1024 * 1024)
        
//        NMLog.createLog(withDirectory: path, filename: "nmlog", context: 0, key: "Kj4Lm6pRtYwZx2v5y7u0i3o9q8a1s3d5fHgJkMnPrT", iv: "Bz3NtR6V9X2S5W8Q")
        NMLog.createLog(withDirectory: path, filename: "nmlog", context: 0)
    }
}

