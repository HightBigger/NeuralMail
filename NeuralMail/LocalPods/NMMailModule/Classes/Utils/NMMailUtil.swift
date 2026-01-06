//
//  NMMailUtil.swift
//  Pods
//
//  Created by 小大 on 2025/12/31.
//

import Foundation

public extension String {
    
    /// 将 IMAP mUTF-7 格式 (如 "&W8RO9lOM-") 解码为人类可读字符串 (如 "收件箱")
    var imapDecoded: String {
        // 如果不包含 &，说明是纯 ASCII，直接返回 (性能优化)
        guard self.contains("&") else { return self }
        
        var result = ""
        var i = self.startIndex
        
        while i < self.endIndex {
            let char = self[i]
            
            if char == "&" {
                i = self.index(after: i)
                guard i < self.endIndex else { break }
                
                // 处理 "&-" 转义为 "&" 的情况
                if self[i] == "-" {
                    result.append("&")
                    i = self.index(after: i)
                    continue
                }
                
                // 寻找结束符 '-'
                let start = i
                while i < self.endIndex && self[i] != "-" {
                    i = self.index(after: i)
                }
                
                // 提取中间的 Base64 字符串
                let encodedPart = String(self[start..<i])
                if let decodedPart = decodeIMAPBase64(encodedPart) {
                    result.append(decodedPart)
                } else {
                    // 如果解码失败，保留原样 (容错)
                    result.append("&" + encodedPart + "-")
                }
                
                // 跳过结束符 '-'
                if i < self.endIndex {
                    i = self.index(after: i)
                }
            } else {
                result.append(char)
                i = self.index(after: i)
            }
        }
        return result
    }
    
    // MARK: - 私有辅助方法
    
    private func decodeIMAPBase64(_ string: String) -> String? {
        // 1. IMAP 规则替换: ',' -> '/'
        var base64 = string.replacingOccurrences(of: ",", with: "/")
        
        // 2. 补全 Base64 Padding ('=')
        let mod = base64.count % 4
        if mod > 0 {
            base64 += String(repeating: "=", count: 4 - mod)
        }
        
        // 3. 解码为 Data
        guard let data = Data(base64Encoded: base64) else { return nil }
        
        // 4. mUTF-7 使用的是 UTF-16 Big Endian
        return String(data: data, encoding: .utf16BigEndian)
    }
}
