//
//  SceneDelegate.swift
//  NeuralMail
//
//  Created by 小大 on 2025/12/8.
//

import UIKit
import NMModular

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: NMAppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        appCoordinator = NMAppCoordinator(window: window)
        appCoordinator?.start()
        
        // 3. 监听/轮询模块状态，决定何时切换主页
        Task {
            // 如果模块还没初始化完，这里可以等待
            // 建议给 ModuleManager 加一个属性: public private(set) var isReady: Bool
            while !NMModuleManager.shared.isReady {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s 轮询
            }
            
            // 4. 模块准备好了，切换 UI
            await MainActor.run {
                appCoordinator?.splashViewControllerDidFinish()
            }
        }
  
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

