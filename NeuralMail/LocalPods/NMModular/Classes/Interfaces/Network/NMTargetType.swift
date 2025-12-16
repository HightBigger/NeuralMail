//
//  NMTargetType.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation

public enum NMHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

/// 定义请求任务类型 (解耦 Alamofire 的关键)
public enum NMTask {
    /// 普通请求 (无参数)
    case requestPlain
    
    /// 带参数请求 (自动匹配编码：GET用URL，POST用JSON)
    case requestParameters(parameters: [String: Any])
    
    /// 自定义编码请求 (明确指定 JSON 或 URL 编码)
    case requestComposite(parameters: [String: Any], encoding: NMParameterEncoding)
    
    /// 上传 (Multipart) - 专门为邮件附件设计
    case uploadMultipart([NMMultipartFormData])
}

public enum NMParameterEncoding {
    case url
    case json
}

/// Multipart 数据封装 (为了不让 Core 依赖 Alamofire，我们需要自己定义一个结构体)
public struct NMMultipartFormData {
    public let data: Data
    public let name: String
    public let fileName: String?
    public let mimeType: String?
    
    public init(data: Data, name: String, fileName: String? = nil, mimeType: String? = nil) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

/// 核心协议：所有 API 定义都需要遵守
public protocol NMTargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: NMHTTPMethod { get }
    var task: NMTask { get }
    var headers: [String: String]? { get }
}
