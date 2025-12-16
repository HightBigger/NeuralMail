//
//  NMNetworkServiceImpl.swift
//  NMNetworkModule
//
//  Created by 小大 on 2025/12/12.
//

import Foundation
import Alamofire
import NMModular

final class NMNetworkServiceImpl {

    // 使用 var 允许后续重新配置 (例如 ServerTrustManager)
    private var session: Session
    private var reachability: NetworkReachabilityManager?
    
    // 拦截器列表
    private var interceptors: [NMNetworkInterceptor] = []
    // 公共 Header 缓存
    private var commonHeaders: [String: String] = [:]
    
    init() {
        // A. 基础配置
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300 // 附件下载允许更长时间
        config.requestCachePolicy = .useProtocolCachePolicy
        
        // B. 初始化 Session (暂时不带 Pinning，start 时根据环境配置)
        self.session = Session(configuration: config)
    }
    
    // MARK: - 初始化阶段调用的配置方法
    
    func configureEnvironment(isDebug: Bool) {
        // C. 安全策略配置
        if isDebug {
            // Debug 模式：允许抓包，不验证证书，打印详细日志
            // self.session = Session(..., serverTrustManager: nil)
            // 甚至可以注入 ConsoleLogger
        } else {
            // Release 模式：启用 SSL Pinning
            let trustManager = ServerTrustManager(evaluators: [
                "api.neuralmail.com": PinnedCertificatesTrustEvaluator()
            ])
            // 需要重新创建 Session 才能应用 TrustManager
            self.session = Session(configuration: session.sessionConfiguration, serverTrustManager: trustManager)
        }
    }
    
    func updateCommonHeader(key: String, value: String) {
        commonHeaders[key] = value
        // 也可以直接注入到 Alamofire 的 Adapter 中
    }
    
    func startReachabilityMonitoring() {
        reachability = NetworkReachabilityManager()
        reachability?.startListening(onUpdatePerforming: { status in
            switch status {
            case .notReachable:
                print("❌ Network Lost")
                // 可以发送 EventBus 通知或使用 NotificationCenter
            case .reachable(.ethernetOrWiFi):
                print("✅ WiFi Connected")
            case .reachable(.cellular):
                print("✅ Cellular Connected")
            case .unknown:
                break
            }
        })
    }
    
    // ... request 方法实现 (记得将 commonHeaders 合并进去) ...
}

extension NMNetworkServiceImpl : NMNetworkService {
    
    func request<T>(_ target: any NMModular.NMTargetType) async throws -> T where T : Decodable {
        return T.self as! T
    }
    
    func register(interceptor: any NMModular.NMNetworkInterceptor) {
        
    }
}
