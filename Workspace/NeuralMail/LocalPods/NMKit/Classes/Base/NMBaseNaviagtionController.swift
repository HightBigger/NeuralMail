//
//  NMBaseNaviagtionController.swift
//  NMKit
//
//  Created by 小大 on 2025/12/15.
//

import UIKit

open class NMBaseNavigationController: UINavigationController {
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupPopGesture()
    }
    
    // MARK: - 1. 视觉配置 (Appearance)
    
    private func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // 背景色 (使用 NMKit 主题色)
        appearance.backgroundColor = NMColor.backgroundApp
        
        // 去掉阴影/分割线 (现在的设计潮流通常是去掉这根黑线)
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        
        // 标题样式
        appearance.titleTextAttributes = [
            .foregroundColor: NMColor.textPrimary
        ]
        
        // 按钮颜色 (Back 箭头颜色)
        self.navigationBar.tintColor = NMColor.textPrimary
        
        // 应用配置
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.compactAppearance = appearance
        
        // 半透明效果关闭 (避免布局坐标系从 (0,0) 开始导致的各种偏移问题)
        self.navigationBar.isTranslucent = false
    }
    
    // MARK: - 2. 拦截 Push (处理 TabBar 和返回按钮)
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            // A. 自动隐藏 TabBar
            viewController.hidesBottomBarWhenPushed = true
            
            // B. 统一返回按钮样式 (去掉文字，只留箭头)
            // 注意：这实际上是修改"上一个"页面的 backBarButtonItem
            let backItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            viewControllers.last?.navigationItem.backBarButtonItem = backItem
            
            // 如果你想完全自定义图标 (非系统箭头)，可以在这里设置 viewController.navigationItem.leftBarButtonItem
            // 但那样会彻底破坏系统侧滑，需要自己写更多手势逻辑。
            // 推荐方案：仅修改 backBarButtonItem 的 title 为空，保留系统箭头和手势。
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    // MARK: - 3. 修复侧滑手势 (Pop Gesture)
    
    private func setupPopGesture() {
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    // MARK: - 4. 状态栏与旋转控制 (Delegation)
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
}

// MARK: - UIGestureRecognizerDelegate

extension NMBaseNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果是根控制器 (Root VC)，禁止侧滑返回，防止假死
        if viewControllers.count <= 1 {
            return false
        }
        return true
    }
}
