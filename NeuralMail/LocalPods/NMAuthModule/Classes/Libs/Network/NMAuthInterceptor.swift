//
//  NMAuthInterceptor.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import NMModular

final class NMAuthInterceptor: NMNetworkInterceptor {
    
    func adapt(_ request: URLRequest) async -> URLRequest {
        var req = request
        // 建议封装一个 KeychainHelper，这里用 UserDefaults 演示
        if let token = UserDefaults.standard.string(forKey: "nm_access_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return req
    }
}
