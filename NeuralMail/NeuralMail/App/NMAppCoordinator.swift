import UIKit
import SwiftUI
import NMKit
import NMAuthModule
import NMModular

class NMAppCoordinator {
    
    @NMLogger("NMApp") var logger
    
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        window.rootViewController = NMNavigationController(rootViewController: NMSplashViewController())
        window.makeKeyAndVisible()
        
        setupObservers()
    }
    
    func splashViewControllerDidFinish() {
        // Check if user is logged in
        checkLoginAndSwitchRoot()
    }
    
    // MARK: - 核心路由逻辑
    private func checkLoginAndSwitchRoot() {
        // 1. 获取 Auth 服务
        guard let authService = NMServiceContainer.shared.resolve(NMAuthService.self) else {
            // 极端情况：Auth 服务没注册，显示错误页或默认去登录
            switchToError()
            return
        }
        
        // 2. 核心判断
        if authService.isLoggedIn {
            logger.info("[App] User is logged in. Going to Main.")
            switchToMain()
        } else {
            logger.info("[App] User not logged in. Going to Login.")
            switchToLogin()
        }
    }
    
    // MARK: - 页面切换
    
    private func switchToLogin() {
        
        // 2. 初始化你的 SwiftUI 视图
        //        let swiftUIView = AITestView()
        //
        //        // 3. 用 UIHostingController 把它包起来
        //        let hostingController = UIHostingController(rootView: swiftUIView)
        //
        //        // 4. (可选) 设置弹出样式，比如全屏或卡片
        //        hostingController.modalPresentationStyle = .pageSheet
        //
        //        setRoot(hostingController)
        //
        //        return
        // 这里通过路由获取
        if let loginVC = NMRouter.shared.match(url: "/auth/login") {
            let nav = NMNavigationController(rootViewController: loginVC)
            setRoot(nav)
        }
    }
    
    private func switchToMain() {
        let nav = NMMainTabBarController()
        setRoot(nav)
    }
    
    private func switchToError() {
        let mainVC = UIViewController() // 占位
        mainVC.view.backgroundColor = .white
        mainVC.title = "Error"
        let nav = NMNavigationController(rootViewController: mainVC)
        setRoot(nav)
    }
    
    private func setRoot(_ vc: UIViewController) {
        // 简单的转场动画
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.window.rootViewController = vc
        }, completion: nil)
    }
    
    // MARK: - 通知监听
    
    private func setupObservers() {
        // 监听登录成功 -> 切换到主页
        NotificationCenter.default.addObserver(forName: .NMUserDidLogin, object: nil, queue: .main) { [weak self] _ in
            self?.switchToMain()
        }
        
        // 监听登出 -> 切换到登录页
        NotificationCenter.default.addObserver(forName: .NMUserDidLogout, object: nil, queue: .main) { [weak self] _ in
            self?.switchToLogin()
        }
    }
}
