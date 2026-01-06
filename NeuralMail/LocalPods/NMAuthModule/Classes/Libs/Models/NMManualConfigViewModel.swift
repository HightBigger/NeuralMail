//
//  NMManualConfigViewModel.swift
//  NMAuthModule
//
//  Created by NeuralMail on 2025/12/30.
//

import Foundation
import Combine
import NMModular
import NMKit

public class NMManualConfigViewModel: ObservableObject {
    
    // MARK: - 依赖注入 (Services)
    @NMLogger("NMAuthModule") var logger
    @NMInjected private var authService: NMAuthService
    @NMInjected private var mailService: NMMailService
    @NMInjected private var featureService: NMFeatureService
    
    // MARK: - 输入数据 (从上一页传来的)
    let email: String
    let password: String
    
    // MARK: - UI 绑定状态 (Outputs -> View)
    
    // Incoming
    @Published var incomingHost: String = ""
    @Published var incomingPort: String = "993"
    @Published var isIncomingSSL: Bool = true
    
    // Outgoing
    @Published var outgoingHost: String = ""
    @Published var outgoingPort: String = "465"
    @Published var isOutgoingSSL: Bool = true
    
    // 状态控制
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLoginSuccess: Bool = false
    
    // 协议类型
    enum ProtocolType: Int {
        case imap = 0
        case pop3 = 1
        case exchange = 2
    }
    @Published var currentProtocol: ProtocolType = .imap
    
    // MARK: - Init
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
        
        // 初始化时尝试预填
        prefillCommonHosts(email: email)
    }
    
    // MARK: - 业务逻辑 (Actions)
    
    /// 预填 Host/Port 逻辑
    private func prefillCommonHosts(email: String) {
        
        if let provider = NMEmailConfigLoader.shared.findProvider(for: email) {
            // 如果有自动发现的信息
            incomingHost = provider.incoming.host
            incomingPort = "\(provider.incoming.port)"
            isIncomingSSL = provider.incoming.isSecure
            
            outgoingHost = provider.outgoing.host
            outgoingPort = "\(provider.outgoing.port)"
            isOutgoingSSL = provider.outgoing.isSecure
        } else {
            // 没有信息，尝试简单的猜测 (可选)
            // let domain = email.split(separator: "@").last ?? ""
            // incomingHost = "imap.\(domain)" ...
        }
    }
    
    /// 处理协议切换
    func updateProtocol(_ type: ProtocolType) {
        self.currentProtocol = type
        switch type {
        case .imap:
            incomingPort = "993"
            isIncomingSSL = true
        case .pop3:
            incomingPort = "995"
            isIncomingSSL = true
        case .exchange:
            incomingPort = "443"
            isIncomingSSL = true
        }
    }
    
    /// 处理 SSL 开关切换的联动逻辑
    func toggleIncomingSSL(_ isOn: Bool) {
        isIncomingSSL = isOn
        // 简单联动逻辑
        if currentProtocol == .imap {
            incomingPort = isOn ? "993" : "143"
        } else if currentProtocol == .pop3 {
            incomingPort = isOn ? "995" : "110"
        }
    }
    
    func toggleOutgoingSSL(_ isOn: Bool) {
        isOutgoingSSL = isOn
        outgoingPort = isOn ? "465" : "587"
    }
    
    /// 核心登录逻辑
    @MainActor
    func login() {
        // 1. 校验
        guard !incomingHost.isEmpty, !incomingPort.isEmpty,
              !outgoingHost.isEmpty, !outgoingPort.isEmpty else {
            self.errorMessage = "config_login_config_error".auth_localized
            return
        }
        
        guard let inPortInt = Int(incomingPort), let _ = Int(outgoingPort) else {
            self.errorMessage = "config_login_port_error".auth_localized
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        // 2. 准备参数
        let components = email.split(separator: "@")
        let username = String(components[0]).lowercased().trimmingCharacters(in: .whitespaces)
        
        // 注意：这里需要根据 currentProtocol 转换 NMMailConfig 的 protocolType
        // 假设 NMMailConfig 的 protocolType 和这里的定义一致
        let configProtocol: NMMailProtocolType = (currentProtocol == .pop3) ? .pop3 : .imap
        
        let config = NMMailConfig(
            email: email,
            host: incomingHost,
            port: inPortInt,
            ssl: isIncomingSSL,
            username: username, // 注意：有些服务器要求 username 是完整邮箱，这里视具体情况而定，暂用 email 前缀
            password: password,
            protocolType: configProtocol
        )
        // 实际上 NMMailConfig 可能还需要 outgoing 的配置，这里假设 connect 主要测 Incoming
        
        Task {
            do {
                try await authService.login(config: config)
                
                //fetchSideBarFolders
                _ = try await featureService.fetchSideBarFolders()
                
                self.isLoading = false
                self.isLoginSuccess = true
                
            } catch {
                self.isLoading = false
                // 错误处理优化
                let nsError = error as NSError
                if nsError.domain == "MCOErrorDomain" && nsError.code == 1 {
                    self.errorMessage = "config_login_auth_error".auth_localized
                } else {
                     self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
