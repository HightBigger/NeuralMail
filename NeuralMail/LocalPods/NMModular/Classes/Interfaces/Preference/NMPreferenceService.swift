//
//  NMPreferenceService.swift
//  NMModular
//
//  Created by 小大 on 2025/12/12.
//

import Foundation
import UIKit

// MARK: - Enums
/// 支持的语言
public enum NMLanguage: String, CaseIterable, Codable {
    case english = "en"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case system = "system"// 跟随系统
}

/// 支持的主题风格
public enum NMThemeStyle: Int, CaseIterable, Codable {
    case system = 0 // 跟随系统
    case light = 1  // 浅色模式
    case dark = 2   // 深色模式
    
    public var displayName: String {
        switch self {
        case .system: return "Follow System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    // 转换为 UIKit 的样式
    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Notification

public extension Notification.Name {
    /// 偏好设置变更通知 (UserInfo 包含 changedKey)
    static let NMPreferenceDidChange = Notification.Name("NMPreferenceDidChange")
}

// MARK: - Protocol

/// 统一的偏好设置服务
public protocol NMPreferenceService {
 
    /// 当前选中的语言
    var language: NMLanguage { get }
    
    var effectiveLanguage: String { get }
    
    /// 当前选中的主题
    var themeStyle: NMThemeStyle { get }
    var isDarkTheme: Bool { get }
    
    // --- Actions ---
    
    /// 切换语言
    /// - Parameter lang: 目标语言
    func setLanguage(_ lang: NMLanguage)
    
    /// 切换主题
    /// - Parameter style: 目标样式
    func setTheme(_ style: NMThemeStyle)
    
    /// 应用当前设置 (通常在 App 启动或模块初始化时调用)
    func applyConfiguration()
}
