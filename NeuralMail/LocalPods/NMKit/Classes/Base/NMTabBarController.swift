//
//  NMTabBarController.swift
//  NMFeatureModule
//
//  Created by 小大 on 2025/12/26.
//

import UIKit
import NMModular

/// TabBar 控制器基类
/// 职责:
/// 1. 统一的外观配置 (iOS 15+ Appearance)
/// 2. 响应主题切换 (跟随系统或强制黑白)
/// 3. 屏幕旋转/状态栏样式的透传控制
open class NMTabBarController: UITabBarController {
    
    // MARK: - Dependencies
    
    // 注入偏好设置服务，用于获取当前主题
    // 使用 Optional 是为了防止服务未注册导致 UI 崩溃 (UI 层应尽量健壮)
    @NMOptionalInjected private var preferenceService: NMPreferenceService?
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 基础 UI 配置
        setupAppearance()
        
        // 2. 初始化主题
        applyCurrentTheme()
        
        // 3. 监听设置变更通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePreferenceChange(_:)),
            name: .NMPreferenceDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Configuration
    
    /// 配置 TabBar 外观 (适配 iOS 13/15+)
    private func setupAppearance() {
        // 使用系统背景色
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .systemBlue // 选中颜色
        tabBar.unselectedItemTintColor = .secondaryLabel // 未选中颜色
        
        // 适配 iOS 15+ 的透明栏问题
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            // 去掉顶部的分割线阴影 (可选)
             appearance.shadowImage = UIImage()
             appearance.shadowColor = .clear
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    // MARK: - Theme Management
    
    /// 应用当前主题
    private func applyCurrentTheme() {
        guard let service = preferenceService else { return }
        
        // 获取当前设置的主题 (System / Light / Dark)
        let style = service.themeStyle
        
        // 强制覆盖当前 Window 的样式
        // 注意：iOS 13+ 支持 overrideUserInterfaceStyle
        // 如果是 .system (0)，设为 .unspecified，系统会自动处理
        self.overrideUserInterfaceStyle = style.userInterfaceStyle
    }
    
    @objc private func handlePreferenceChange(_ notification: Notification) {
        // 在主线程更新 UI
        DispatchQueue.main.async { [weak self] in
            self?.applyCurrentTheme()
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Orientation & Status Bar (透传)
    
    // 下面这些方法非常重要。
    // TabBarController 本身通常不决定能否旋转，而是应该听从当前选中的那个子 VC。
    
    open override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return selectedViewController
    }
}
