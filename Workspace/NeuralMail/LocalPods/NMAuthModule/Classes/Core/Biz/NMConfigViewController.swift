//
//  NMConfigViewController.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/16.
//

import UIKit
import NMKit
import NMModular // 引入 NMMailConfig 定义

//class MailConfigViewController: NMBaseViewController {
//    
//    // MARK: - UI Components
//    
//    private let protocolSegment = UISegmentedControl(items: ["IMAP", "Exchange", "POP3"])
//    
//    // Incoming
//    private let incomingHeader = NMLabel(style: .sectionHeader, text: "INCOMING SERVER")
//    private let imapHostField = NMTextField(placeholder: "Hostname", icon: "server.rack")
//    private let imapPortField = NMTextField(placeholder: "Port", text: "993", keyboardType: .numberPad)
//    private let imapSecurityField = NMTextField(placeholder: "Security", text: "SSL/TLS") // 实际可用 Picker
//    
//    // Outgoing
//    private let outgoingHeader = NMLabel(style: .sectionHeader, text: "OUTGOING SERVER")
//    private let smtpHostField = NMTextField(placeholder: "Hostname", icon: "paperplane")
//    private let smtpPortField = NMTextField(placeholder: "Port", text: "465", keyboardType: .numberPad)
//    
//    // Action
//    private let connectButton = NMButton(title: "Log In", style: .primary)
//    
//    // MARK: - Logic
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        
//        // 绑定智能逻辑
//        imapHostField.addTarget(self, action: #selector(didChangeHost), for: .editingDidEnd)
//    }
//    
//    @objc private func didTapConnect() {
//        // 1. 校验输入
//        guard let email = emailField.text, let password = passwordField.text else { return }
//        
//        // 2. 组装 Config 模型 (定义在 NMModular)
//        let config = NMMailConfig(
//            email: email,
//            host: imapHostField.text ?? "",
//            port: Int(imapPortField.text ?? "993") ?? 993,
//            username: email, // 默认用户名=邮箱
//            password: password,
//            protocolType: selectedProtocol // .imap or .pop3
//        )
//        
//        // 3. 调用 MailModule 服务进行连接测试
//        connectButton.isLoading = true
//        
//        Task {
//            do {
//                let mailService = NMServiceContainer.shared.resolve(NMMailClientService.self)
//                // 尝试连接
//                try await mailService?.connect(config: config)
//                
//                // 连接成功，保存账号并跳转
//                handleLoginSuccess()
//            } catch {
//                NMToast.show(error.localizedDescription)
//            }
//            connectButton.isLoading = false
//        }
//    }
//    
//    //  Neural Feature: 简单的规则推断
//    @objc private func didChangeHost() {
//        guard let host = imapHostField.text?.lowercased() else { return }
//        
//        if host.contains("qq.com") || host.contains("163.com") {
//            imapPortField.text = "993"
//            // smtpHostField.text 也可以自动推断
//        } else if host.contains("office365") {
//            protocolSegment.selectedSegmentIndex = 1 // Exchange
//        }
//    }
//}
