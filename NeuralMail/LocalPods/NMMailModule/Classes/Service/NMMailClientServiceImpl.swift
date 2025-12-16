//
//  NMAuthServiceImpl.swift
//  NMModular
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import MailCore
import NMModular

final class NMMailClientServiceImpl: NMMailClientService {
    
    // 保持 Session 存活
    private var imapSession: MCOIMAPSession?
    // private var popSession: MCOPOPSession? // 后续扩展 POP3
    
    private var currentConfig: NMMailConfig?
    
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
        session.connectionType = .TLS // 生产环境建议根据端口(993/143)自动判断
        
        // 验证连接 (Check Account)
        // 将 MailCore 的 Operation 转换为 Async
        return try await withCheckedThrowingContinuation { continuation in
            let op = session.checkAccountOperation()
            op?.start { error in
                if let err = error {
                    continuation.resume(throwing: err)
                } else {
                    self.imapSession = session
                    print("✅ [MailCore] Connected to \(config.host)")
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Fetch Folders
    
    func fetchFolders() async throws -> [NMMailFolder] {
        guard let session = imapSession else { throw makeError("Session not initialized") }
        
        return try await withCheckedThrowingContinuation { continuation in
            let op = session.fetchAllFoldersOperation()
            op?.start { error, folders in
                if let err = error {
                    continuation.resume(throwing: err)
                    return
                }
                
                // 转换 [MCOIMAPFolder] -> [NMMailFolder]
                let result = (folders ?? []).map { mcoFolder in
                    NMMailFolder(
                        path: mcoFolder.path,
                        displayName: mcoFolder.path, // 简单处理，实际可用 MCOIMAPFolderInfo 解析名称
                        delimiter: Character(String(mcoFolder.delimiter))
                    )
                }
                continuation.resume(returning: result)
            }
        }
    }
    
    // MARK: - Fetch Messages
    
    func fetchMessages(folder: String, offset: Int, limit: Int) async throws -> [NMMailMessage] {
        guard let session = imapSession else { throw makeError("Session not initialized") }
        
        // IMAP 拉取逻辑：通常需要先获取总数，或者使用 IndexSet
        // 这里简化为：拉取最新的 limit 条 (UID 模式)
        // MailCore 的 range 是基于 Sequence Number 的 (1...Total)
        
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
                let result = (messages as? [MCOIMAPMessage] ?? []).compactMap { msg -> NMMailMessage? in
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
