//
//  NMMainTabBarController.swift
//  NeuralMail
//
//  Created by 小大 on 2025/12/26.
//

import NMKit
import NMModular // 引用核心架构

class NMMainTabBarController: NMTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildControllers()
    }

    private func setupChildControllers() {
        var viewControllers: [UIViewController] = []
        
        // 1. 组装邮件模块 (Feature Module)
        // 通过路由获取，完全解耦
        if let mailVC = NMRouter.shared.match(url: "/mail/home") {

            let nav = NMNavigationController(rootViewController: mailVC)
            nav.tabBarItem = UITabBarItem(title: "邮件", image: UIImage(systemName: "envelope"), selectedImage: UIImage(systemName: "envelope.fill"))
            
            viewControllers.append(nav)
        }
        
        let nav = NMNavigationController(rootViewController: UIViewController())
        nav.tabBarItem = UITabBarItem(title: "设置", image: UIImage(systemName: "envelope"), selectedImage: UIImage(systemName: "envelope.fill"))
        viewControllers.append(nav)
        
        // 2. 组装其他模块 (示例)
        // if let calendarVC = NMRouter.shared.match(url: "nm://calendar/home") { ... }
        // if let settingsVC = NMRouter.shared.match(url: "nm://settings/home") { ... }
        
        self.viewControllers = viewControllers
    }
}
