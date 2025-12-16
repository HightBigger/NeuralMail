//
//  NMMailModels.swift
//  Alamofire
//
//  Created by 小大 on 2025/12/16.
//

import Foundation

// MARK: - Enums
public enum NMMailProtocolType {
    case imap     // 标准 IMAP (含 Exchange IMAP)
    case pop3     // POP3
    case exchange // 预留：如果未来接 EWS/Graph
}

// MARK: - Configuration
public struct NMMailConfig {
    public let email: String
    public let host: String
    public let port: Int
    public let username: String
    public let password: String // 实际项目中应传 Token 或从 Keychain 读取
    public let protocolType: NMMailProtocolType
    
    public init(email: String, host: String, port: Int, username: String, password: String, protocolType: NMMailProtocolType = .imap) {
        self.email = email
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.protocolType = protocolType
    }
}

// MARK: - Models (纯 Swift 模型，解耦 MailCore)
public struct NMMailFolder {
    public let path: String
    public let displayName: String
    public let delimiter: Character
    public let flags: Int // 预留给 MailCore flags
    
    public init(path: String, displayName: String, delimiter: Character) {
        self.path = path
        self.displayName = displayName
        self.delimiter = delimiter
        self.flags = 0
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
