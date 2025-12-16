import UIKit
import NMModular

open class NMBaseViewController: UIViewController, NMLocalizable {
        
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocalizedStrings()
        
        // Subscribe to language change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChange), name: .NMPreferenceDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Subclass Hooks
    
    open func setupUI() {
        // Default implementation does nothing
    }
    
    // MARK: - NMLocalizable
    
    /// Override this method to set localized text.
    open func setupLocalizedStrings() {
        // Default implementation does nothing
    }
    

    
    // MARK: - Notification Handler
    
    @objc private func handleLanguageChange(_ notification: Notification) {
  
        // 过滤：只有当改变的是 "language" 时才刷新
        if let userInfo = notification.userInfo,
           let key = userInfo["changedKey"] as? String,
           key == "language" {
   
            DispatchQueue.main.async {
                self.setupLocalizedStrings()
                // 如果需要，也可以在这里调用 self.view.setNeedsLayout()
            }
        }
    }
}
