//
//  NMAuthServiceImpl.swift
//  NMModular
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import MailCore
import NMModular

final class NMMailServiceImpl: NMMailService {
    
    @NMLogger("NMMailModule") var logger
    // 保持 Session 存活
    private var imapSession: MCOIMAPSession?
    // private var popSession: MCOPOPSession? // 后续扩展 POP3
    
    private var currentConfig: NMMailConfig?
    
    private var realInboxPath: String = "INBOX"
    
    var isConnected: Bool {
        return self.imapSession != nil
    }
    
    // MARK: - Connection
    
    func connect(config: NMMailConfig) async throws {
        self.currentConfig = config
        
        switch config.protocolType {
        case .imap, .exchange:
            try await connectIMAP(config: config)
        case .pop3:
            throw NSError(domain: "NMMail", code: -1, userInfo: [NSLocalizedDescriptionKey: "POP3暂未实现"])
        }
    }
    
    private func connectIMAP(config: NMMailConfig) async throws {
        
        let session = MCOIMAPSession()
        session.hostname = config.host
        session.port = UInt32(config.port)
        session.username = config.username
        session.password = config.password
        session.isVoIPEnabled = false
        session.connectionType = config.ssl ? .TLS : .clear
        session.isCheckCertificateEnabled = false;//默认不校验证书
        
        // 设置超时 (建议设置，防止弱网卡死)
        session.timeout = 30.0
        
        let checkOp = session.checkAccountOperation()
        
        try await runVoidOperation(checkOp)

        self.imapSession = session
        
        self.logger.info("checkAccountOperation success:\(config.email) ")
    }
    
    // MARK: - Fetch Folders
    
    func fetchFolders() async throws -> [NMMailFolder] {
        guard let session = imapSession else { throw makeError("Session not initialized") }
        
        let foldersOp = session.fetchAllFoldersOperation()
        
        let mcoFolders = try await runFolderOperation(foldersOp)
        
        if let inboxFolder = mcoFolders.first(where: {
            // 优先信 Flag (0x10)
            ($0.flags.rawValue & MCOIMAPFolderFlag.inbox.rawValue) != 0 ||
            // 其次信名字 (忽略大小写)
            $0.path.caseInsensitiveCompare("INBOX") == .orderedSame
        }) {
            self.realInboxPath = inboxFolder.path
            self.logger.info("🎯 [Connect] 锁定真实收件箱路径: \(self.realInboxPath)")
        }
        
        self.logger.info("fetchFolders success:\(mcoFolders.count) ")
        
        return mcoFolders.map { mcoFolder in
            // 处理 delimiter 转 Character 的崩溃风险
            let delimiterInt = Int(mcoFolder.delimiter)
            let delimiterChar: Character = (delimiterInt > 0 && delimiterInt < 128) ? Character(UnicodeScalar(delimiterInt)!) : "/"
            
            let path = mcoFolder.path // 例如: "&W8RO9lOM-"

            let displayName = imapSession!.defaultNamespace.components(fromPath: path).last as! String
            
            let finalName = displayName.imapDecoded
            print("👉 Debug Path: \(finalName)")
            return NMMailFolder(
                path: mcoFolder.path,
                displayName: finalName,
                delimiter: delimiterChar,
                flags: Int(mcoFolder.flags.rawValue)
            )
        }
    }
    
    // MARK: - Fetch Messages
    func fetchMessages(folder: String, offset: Int, limit: Int) async throws -> [NMMailMessage] {
        guard let session = imapSession else { throw makeError("Session not initialized") }
                
        return try await withCheckedThrowingContinuation { continuation in
            
            // 构造请求：只拉取头部 (Headers) 以节省流量
            let requestKind: MCOIMAPMessagesRequestKind = [.headers, .flags]
            // 构造范围：这里用 MCOIndexSet (MailCore 特有)
            // 实际生产中需要先 folderInfoOperation 获取邮件总数，再计算 range
            let range = MCOIndexSet(range: MCORange(location: UInt64(offset + 1), length: UInt64(limit)))
            
            let op = session.fetchMessagesOperation(withFolder: folder, requestKind: requestKind, uids: range)
            
            op?.start { error, messages, vanishedMessages in
                if let err = error {
                    continuation.resume(throwing: err)
                    return
                }
                
                // 转换 [MCOIMAPMessage] -> [NMMailMessage]
                let result = (messages ?? []).compactMap { msg -> NMMailMessage? in
                    guard let header = msg.header else { return nil }
                    
                    return NMMailMessage(
                        id: "\(msg.uid)",
                        subject: header.subject ?? "No Subject",
                        preview: "", // Preview 需要 fetchBody 或 snippet
                        sender: header.from?.displayName ?? header.from?.mailbox ?? "Unknown",
                        senderEmail: header.from?.mailbox ?? "",
                        date: header.date,
                        isRead: msg.flags.contains(.seen)
                    )
                }
                
                // MailCore 返回顺序可能是旧->新，通常需要反转
                continuation.resume(returning: result.reversed())
            }
        }
    }
    
    func disconnect() {
        self.imapSession = nil
        print("🔌 [MailCore] Disconnected")
    }
    
    // MARK: - Helpers
    
    private func makeError(_ msg: String) -> Error {
        return NSError(domain: "NMMailModule", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
    }
}


// MARK: - Async Helpers (MailCore 转 Swift Concurrency)

extension NMMailServiceImpl {
    
    /// 包装无返回值的操作 (如 checkAccount)
    private func runVoidOperation(_ op: MCOIMAPOperation?) async throws {
        guard let op = op else { return }
        
        return try await withCheckedThrowingContinuation { continuation in
            op.start { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func runIdentityOperation(_ op: MCOIMAPIdentityOperation?) async throws {
        guard let op = op else { return }
        
        return try await withCheckedThrowingContinuation { continuation in
            // 注意这里：回调有两个参数 (error, info)
            // 我们用 "_" 忽略 info，这样既满足了签名，又避免了去读取它导致崩溃
            op.start { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    private func runFolderOperation(_ op: MCOIMAPFetchFoldersOperation?) async throws -> [MCOIMAPFolder] {
        guard let op = op else { return [] }
        
        return try await withCheckedThrowingContinuation { continuation in
            op.start { error, folders in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    // 强制转换结果类型
                    let result = folders ?? []
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    private func runCustomCommandOperation(_ op: MCOIMAPCustomCommandOperation?) async throws {
            guard let op = op else { return }
            
            return try await withCheckedThrowingContinuation { continuation in
                // 强制转换为带 Data 回调的 Block 类型
                // 虽然 op 声明类型是 MCOIMAPOperation，但运行时它会调用带两个参数的 Block
                // 这种写法最为稳妥：
                op.start { res,error in // 使用 "_" 忽略 data
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
}
