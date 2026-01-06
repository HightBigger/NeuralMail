//
//  NMAuthAPI.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import NMModular

enum NMAuthAPI {
    case login(email: String, pass: String)
    case logout
}

extension NMAuthAPI: NMTargetType {
    var baseURL: URL { URL(string: "https://api.neuralmail.com/v1")! }
    
    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .logout: return "/auth/logout"
        }
    }
    
    var method: NMHTTPMethod {
        switch self {
        case .login: return .post
        case .logout: return .post
        }
    }
    
    var task: NMTask {
        switch self {
        case .login(let email, let pass):
            return .requestParameters(parameters: ["email": email, "password": pass])
        case .logout:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? { nil }
}
