//
//  NMMailModels.swift
//  Alamofire
//
//  Created by 小大 on 2025/12/16.
//

import Foundation

// MARK: - Enums
public enum NMMailProtocolType: String {
    case imap
    case pop3
    case exchange  // 这里 Exchange 通常指 EWS 或 ActiveSync，但在 MailCore2 中可能映射为 IMAP
}

// MARK: - Configuration
public struct NMMailConfig {
    public let email: String
    public let host: String
    public let port: Int
    public let ssl: Bool
    public let username: String
    public let password: String // 实际项目中应传 Token 或从 Keychain 读取
    public let protocolType: NMMailProtocolType
    
    public init(email: String, host: String, port: Int,ssl:Bool, username: String, password: String, protocolType: NMMailProtocolType = .imap) {
        self.email = email
        self.host = host
        self.port = port
        self.ssl = ssl
        self.username = username
        self.password = password
        self.protocolType = protocolType
    }
}

// 定义一个 OptionSet，它本质上是一个 Int，但支持 .contains, .insert 等集合操作
public struct NMMailFolderFlags: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    // MARK: - 定义具体的 Flag 值 (参考 MailCore2 MCOIMAPFolderFlag)

    public static let none         = NMMailFolderFlags([])
    public static let marked       = NMMailFolderFlags(rawValue: 1 << 0)
    public static let unmarked     = NMMailFolderFlags(rawValue: 1 << 1)
    public static let noSelect     = NMMailFolderFlags(rawValue: 1 << 2) // 不能被选中的文件夹
    public static let noInferiors  = NMMailFolderFlags(rawValue: 1 << 3) // 不能有子文件夹
    public static let inbox        = NMMailFolderFlags(rawValue: 1 << 4) // 收件箱
    public static let sent         = NMMailFolderFlags(rawValue: 1 << 5) // 已发送
    public static let flagged      = NMMailFolderFlags(rawValue: 1 << 6) // 星标/重要
    public static let all          = NMMailFolderFlags(rawValue: 1 << 7) // 所有邮件
    public static let trash        = NMMailFolderFlags(rawValue: 1 << 8) // 垃圾箱/废纸篓
    public static let drafts       = NMMailFolderFlags(rawValue: 1 << 9) // 草稿箱
    public static let junk         = NMMailFolderFlags(rawValue: 1 << 10)// 垃圾邮件(Spam)
    public static let important    = NMMailFolderFlags(rawValue: 1 << 11)// 重要
    public static let archive      = NMMailFolderFlags(rawValue: 1 << 12)// 归档
}

// MARK: - Models (纯 Swift 模型，解耦 MailCore)
public struct NMMailFolder {
    public let path: String
    public let displayName: String
    public let delimiter: Character
    public let flags: NMMailFolderFlags // 预留给 MailCore flags
    
    // 增加一个辅助判断
    public var isInbox: Bool {
        // MailCore 的 MCOIMAPFolderFlagInbox 值通常是 1 << 4
        // 但为了解耦，最好在 Infra 层的实现里把这个判断做好，或者这里直接引入位运算
        // 简单做法：Infra 层映射时，如果 flags 包含 inbox，就标记
        if flags == .inbox {
            // 0x10 是 MCOIMAPFolderFlagInbox 的值
            return true
        }
        
        if path.caseInsensitiveCompare("INBOX") == .orderedSame {
            return true
        }
            
        return false
    }
    
    
    public init(path: String, displayName: String, delimiter: Character,flags: Int = 0) {
        self.path = path
        self.displayName = displayName
        self.delimiter = delimiter
        self.flags = NMMailFolderFlags(rawValue: flags)
    }
}

public struct NMMailMessage: Identifiable {
    public let id: String // UID
    public let subject: String
    public let preview: String // snippet
    public let sender: String // Display Name
    public let senderEmail: String
    public let date: Date
    public let isRead: Bool
    
    public init(id: String, subject: String, preview: String, sender: String, senderEmail: String, date: Date, isRead: Bool) {
        self.id = id
        self.subject = subject
        self.preview = preview
        self.sender = sender
        self.senderEmail = senderEmail
        self.date = date
        self.isRead = isRead
    }
}
