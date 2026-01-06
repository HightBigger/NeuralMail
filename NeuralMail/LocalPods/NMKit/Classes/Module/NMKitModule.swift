//
//  NMKitModule.swift
//  NMKit
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import UIKit
import NMModular
import IQKeyboardManager

public final class NMKitModule: NMModuleType {
    
    // 优先级设为 Critical 或 High
    // 必须在业务模块 UI 展示之前完成字体和外观配置
    public static var priority: NMModulePriority = .critical
    
    public init() {}
    
    public func registerServices(registry: NMServiceRegistry) {
        // NMKit 不需要提供 Service 给别人注入
    }
    
    public func start(context: NMLaunchContext) async {
        // 1. 注册 Bundle 里的自定义字体
        registerCustomFonts()
        
        // 2. 设置全局 UI 外观 (Appearance Proxy)
        setupGlobalAppearance()
        
        // 3. (可选) 键盘管理器配置
        setupKeyboardManager()
        
        await NMHUD.configure()
        
        print("🎨 [NMKitModule] UI Infrastructure ready.")
    }
    
    // MARK: - Private Setup
    
    private func registerCustomFonts() {
        // 假设你在 Assets 里放了字体文件
        // NMFontLoader.load(name: "MyFont-Regular", bundle: Bundle.nmKit)
    }
    
    private func setupGlobalAppearance() {
        // 虽然 BaseNC 里写了，但某些全局控件 (如 UISwitch, UISlider) 可能也需要统一色调
        UISwitch.appearance().onTintColor = NMColor.textPrimary
        
        // 统一 TabBar 样式
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = NMColor.backgroundApp
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        
        
    }
    
    private func setupKeyboardManager() {

        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().keyboardDistanceFromTextField = 0
        IQKeyboardManager.shared().isEnableAutoToolbar = false
        IQKeyboardManager.shared().toolbarManageBehavior = .byPosition
        
    }
}
