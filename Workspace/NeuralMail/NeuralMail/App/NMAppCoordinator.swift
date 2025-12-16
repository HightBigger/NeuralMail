import UIKit
import NMKit
import NMAuthModule
import NMModular

class NMAppCoordinator: NMCoordinator {
    
    @NMLogger("NMApp") var logger
    
    var navigationController: NMBaseNavigationController
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = NMBaseNavigationController(rootViewController: NMSplashViewController())
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
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
            logger.info("🚀 [App] User is logged in. Going to Main.")
            switchToMain()
        } else {
            logger.info("🛑 [App] User not logged in. Going to Login.")
            switchToLogin()
        }
    }
    
    // MARK: - 页面切换
    
    private func switchToLogin() {
        
        // 这里通过路由获取
        // let loginVC = NMRouter.shared.match(url: "/auth/login")
        if let loginVC = NMRouter.shared.match(url: "/auth/login") {
            let nav = NMBaseNavigationController(rootViewController: loginVC)
            setRoot(nav)
        }
    }
    
    private func switchToMain() {
        // 初始化你的主业务 TabBar
        // let mainVC = MainTabBarController()
        let mainVC = UIViewController() // 占位
        mainVC.view.backgroundColor = .white
        mainVC.title = "Inbox"
        let nav = NMBaseNavigationController(rootViewController: mainVC)
        setRoot(nav)
    }
    
    private func switchToError() {
        // 初始化你的主业务 TabBar
        // let mainVC = MainTabBarController()
        let mainVC = UIViewController() // 占位
        mainVC.view.backgroundColor = .white
        mainVC.title = "Error"
        let nav = NMBaseNavigationController(rootViewController: mainVC)
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


