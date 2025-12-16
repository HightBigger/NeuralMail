//
//  NMColor.swift
//  NMKit
//
//  Created by 小大 on 2025/12/8.
//

import UIKit

private final class NMKitBundleToken {}

public enum NMColor {
    
    /// 安全加载颜色，防止 Crash
    private static func load(named name: String, fallback: UIColor) -> UIColor {
  
        let bundle = Bundle(for: NMKitBundleToken.self)
        
        let path = bundle.path(forResource: "NMKit", ofType: "bundle")
        let resourceBundle = Bundle(path: path!)
        
        return UIColor(named: name, in: resourceBundle, compatibleWith: nil) ?? fallback
    }

    // MARK: - Backgrounds
    
    /// App 最底层背景
    public static var backgroundApp: UIColor {
        load(named: "BackgroundApp", fallback: .systemBackground)
    }
    
    /// 登录框/内容卡片背景
    public static var backgroundCard: UIColor {
        load(named: "BackgroundCard", fallback: .secondarySystemBackground)
    }
    
    /// 输入框背景
    public static var backgroundInput: UIColor {
        load(named: "BackgroundInput", fallback: .systemGray6)
    }
    
    // MARK: - Texts
    
    /// 主要文字 (White in DarkMode)
    public static var textPrimary: UIColor {
        load(named: "TextPrimary", fallback: .label)
    }
    
    /// 次要文字 (Gray)
    public static var textSecondary: UIColor {
        load(named: "TextSecondary", fallback: .secondaryLabel)
    }
    
    /// 品牌紫色文字 ("Mail")
    public static var textBrand: UIColor {
        load(named: "TextBrand", fallback: .systemPurple)
    }
    
    /// 按钮上的文字
    public static var textOnButton: UIColor {
        load(named: "TextOnButton", fallback: .white)
    }
    
    // MARK: - Actions
    
    /// 主按钮背景
    public static var actionPrimary: UIColor {
        load(named: "ActionPrimary", fallback: .systemBlue)
    }
    
    /// 辅助按钮背景
    public static var actionSecondary: UIColor {
        load(named: "ActionSecondary", fallback: .systemGray4)
    }
    
    /// 输入框边框
    public static var borderInput: UIColor {
        load(named: "BorderInput", fallback: .opaqueSeparator)
    }
    
    // MARK: - Gradient Colors
    
    // 这里使用扩展里的 init(hex:)
    public static let gradientStart = UIColor(hex: "#C56CFF")
    public static let gradientEnd = UIColor(hex: "#6E44FF")
}

// 辅助：如果你需要直接在代码里用 Hex 创建颜色（比如渐变色）
public extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
