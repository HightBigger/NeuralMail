//
//  NMHUD.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/25.
//

import UIKit
import KRProgressHUD
import SwiftMessages

public class NMHUD {
    
    // MARK: - Initialization
    
    /// 在 AppDelegate 的 didFinishLaunching 中调用，进行全局配置
    @MainActor
    public static func configure() {
        // 配置 KRProgressHUD (Loading)
        // 使用语义化颜色：.systemBackground (亮:白 / 暗:黑), .label (亮:黑 / 暗:白)
        KRProgressHUD.set(style: .custom(
            background: .secondarySystemGroupedBackground,
            text: .label,
            icon: .label
        ))
        // 遮罩使用半透明黑色，无论黑白模式都适用
        KRProgressHUD.set(maskType: .black)
        // 设置超时时间，防止网络卡死Loading一直转
        KRProgressHUD.set(deadline: 30)
    }

    // MARK: - Loading (阻断式 - KRProgressHUD)
    
    /// 显示全屏加载 (阻断用户操作)
    /// - Parameter message: 提示语 (可选)
    public static func showLoading(_ message: String? = nil) {
        DispatchQueue.main.async {
            if let msg = message {
                KRProgressHUD.show(withMessage: msg)
            } else {
                KRProgressHUD.show()
            }
        }
    }
    
    /// 隐藏全屏加载
    public static func dismiss() {
        DispatchQueue.main.async {
            KRProgressHUD.dismiss()
        }
    }
    
    // MARK: - Toast / Notification (非阻断式 - SwiftMessages)
    
    public enum MessageType {
        case success
        case error
        case warning
        case info
    }
    
    /// 显示顶部状态提示 (不阻断操作，自动消失)
    /// - Parameters:
    ///   - type: 类型 (成功/失败/警告/信息)
    ///   - title: 标题 (可选)
    ///   - body: 内容
    public static func showToast(type: MessageType, title: String = "", body: String) {
        DispatchQueue.main.async {
            // 1. 创建视图 (使用 CardView 样式，类似系统通知)
            let view = MessageView.viewFromNib(layout: .cardView)
            
            // 2. 配置内容
            view.configureContent(title: title, body: body)
            view.button?.isHidden = true // 通常 Toast 不需要按钮
            
            // 3. 配置 Dark Mode 动态颜色
            // 我们不使用 SwiftMessages 默认的 .success/.error 主题颜色，因为它们太亮眼且不一定适配深色
            // 我们手动配置背景色为“系统浮层背景色”
            view.backgroundView.backgroundColor = .secondarySystemGroupedBackground
            view.backgroundView.layer.cornerRadius = 10
            
            // 配置文字颜色
            view.titleLabel?.textColor = .label
            view.bodyLabel?.textColor = .secondaryLabel
            
            // 4. 根据类型配置图标和侧边条颜色
            let iconStyle: IconStyle = .default
            var accentColor: UIColor = .systemBlue
            var iconImage: UIImage? = nil
            
            switch type {
            case .success:
                accentColor = .systemGreen
                iconImage = Icon.success.image
            case .error:
                accentColor = .systemRed
                iconImage = Icon.error.image
                // 错误提示可以加震动反馈
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .warning:
                accentColor = .systemOrange
                iconImage = Icon.warning.image
            case .info:
                accentColor = .systemBlue
                iconImage = Icon.info.image
            }
            
            // 设置左侧图标
            view.configureTheme(backgroundColor: .clear, foregroundColor: accentColor, iconImage: iconImage, iconText: nil)
            
            // 这里为了适配深色模式，我们只用 accentColor 染图标，背景依然保持 systemBackground
            // SwiftMessages 默认 theme 会改背景色，所以上面手动设置背景色要在 configureTheme 之后再次确认(如果被覆盖)
            view.backgroundView.backgroundColor = .secondarySystemGroupedBackground
            
            // 5. 显示配置
            var config = SwiftMessages.Config()
            config.presentationStyle = .top // 顶部滑下
            config.presentationContext = .window(windowLevel: .statusBar)
            config.duration = .seconds(seconds: 3) // 3秒后消失
            config.dimMode = .none // 不遮挡背景，用户可以继续操作
            config.interactiveHide = true // 允许用户向上滑动关闭
            
            // 显示
            SwiftMessages.show(config: config, view: view)
        }
    }
}
