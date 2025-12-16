//
//  AppDelegate.swift
//  NeuralMail
//
//  Created by 小大 on 2025/12/8.
//

import UIKit
import NMModular
import NMLogModule
import NMDataModule
import NMNetworkModule
import NMAuthModule
import NMKit
import NMPreferenceModule

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("AppDelegate: 开始注册模块...")
        
        // 1. 准备启动上下文
        let context = NMLaunchContext(
            launchOptions: launchOptions,
            isDebug: {
#if DEBUG
                return true
#else
                return false
#endif
            }()
        )
        
        // 2. 注册所有业务模块
        // 注意：这里只是把类注册进管理器，尚未实例化服务
        NMModuleManager.shared.register(modules: [
            NMLogModule(),
            NMDataModule(),
            NMNetworkModule(),
            NMKitModule(),
            NMPreferenceModule(),
            NMAuthModule(),
//            NMChatModule(),
//            NMNetworkModule(), // 假设有
//            NMConfigModule()   // 假设有
        ])
        
        // 3. 启动引擎
        // 这里使用 Task 是因为 start 流程支持异步
        Task {
            await NMModuleManager.shared.startup(context: context)            
        }
        
        print("AppDelegate: 模块初始化完成")

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: Application Lifecycle
    
    func applicationWillResignActive(_ application: UIApplication) {

    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NMModuleManager.shared.applicationDidEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {

    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {

    }
    
    func applicationWillTerminate(_ application: UIApplication) {

    }


}


