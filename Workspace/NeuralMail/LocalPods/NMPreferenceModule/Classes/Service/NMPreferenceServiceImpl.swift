//
//  NMAuthServiceImpl.swift
//  NMModular
//
//  Created by 小大 on 2025/12/15.
//

import Foundation
import UIKit
import NMModular

final class NMPreferenceServiceImpl: NMPreferenceService {
   
    // 注入日志
    @NMLogger("Preference") var logger
    
    // MARK: - Keys
    
    private let kLanguageKey = "nm_pref_language"
    private let kThemeKey = "nm_pref_theme"
    
    // MARK: - Properties
    
    private(set) var language: NMLanguage = .system
    private(set) var themeStyle: NMThemeStyle = .system
    
    // 实现协议属性
    var effectiveLanguage: String {
        return getEffectiveLanguage()
    }
    
    var isDarkTheme: Bool {
        switch self.themeStyle {
        case .dark:
            return true
        case .light:
            return false
        case .system:
            // 核心：当设置为"跟随系统"时，读取当前界面的特征集合
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
    
    // MARK: - Init
    
    init() {
        loadPreferences()
    }
    
    // MARK: - Implementation
    
    func setLanguage(_ lang: NMLanguage) {
        guard language != lang else { return }
        
        logger.info("Switching language to: \(lang.rawValue)")
        
        let oldEffectiveLanguage = self.effectiveLanguage
        
        self.language = lang
        
        // 1. 持久化
        if let data = try? JSONEncoder().encode(lang) {
            UserDefaults.standard.set(data, forKey: kLanguageKey)
        }
        
        if oldEffectiveLanguage != self.effectiveLanguage {
            //生效语言没变，则不发通知
            notifyChange(key: "language")
        }
    }
    
    func setTheme(_ style: NMThemeStyle) {
        guard themeStyle != style else { return }
        
        logger.info("Switching theme to: \(style.displayName)")
        
        let oldThemeIsDark = self.isDarkTheme
        
        self.themeStyle = style
        
        // 1. 持久化
        UserDefaults.standard.set(style.rawValue, forKey: kThemeKey)
        
        if oldThemeIsDark != self.isDarkTheme {
            //生效主体没变，则不发通知
            performThemeUpdate(style)
            notifyChange(key: "theme")
        }
    }
    
    func applyConfiguration() {
        logger.info("Applying initial preferences...")
        // 主要是应用主题，语言通常是被动读取的
        performThemeUpdate(self.themeStyle)
    }
    
    // MARK: - Private Helpers
    
    private func loadPreferences() {
        // Load Language
        if let data = UserDefaults.standard.data(forKey: kLanguageKey),
           let savedLang = try? JSONDecoder().decode(NMLanguage.self, from: data) {
            self.language = savedLang
        } else {
            self.language = .system
        }
        
        // Load Theme
        let themeVal = UserDefaults.standard.integer(forKey: kThemeKey)
        self.themeStyle = NMThemeStyle(rawValue: themeVal) ?? .system
    }
    
    private func getEffectiveLanguage() -> String{
        
        if self.language == .system{
            let supportedLanguages = NMLanguage.allCases
                        .filter { $0 != .system }
                        .map { $0.rawValue }
            let systemPreferred = Locale.preferredLanguages
            let bestMatch = Bundle.preferredLocalizations(from: supportedLanguages, forPreferences: systemPreferred).first
            
            return bestMatch ?? NMLanguage.english.rawValue
        }
        
        return self.language.rawValue
    }
        
    private func notifyChange(key: String) {
        NotificationCenter.default.post(
            name: .NMPreferenceDidChange,
            object: self,
            userInfo: ["changedKey": key]
        )
    }
    
    /// 执行 UIWindow 的样式修改
    private func performThemeUpdate(_ style: NMThemeStyle) {
        // 必须在主线程操作 UI
        Task { @MainActor in
            // 遍历所有活跃场景的 Window
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { window in
                    // 强制覆盖 InterfaceStyle
                    window.overrideUserInterfaceStyle = style.userInterfaceStyle
                }
            
            // 某些情况下需要刷新当前视图
            // window.setNeedsLayout()
        }
    }
}
