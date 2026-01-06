//
//  NMMailDetailViewController.swift
//  NMFeatureModule
//
//  Created by 小大 on 2025/12/26.
//

import NMKit
import WebKit
import NMModular

class NMMailDetailViewController: UIViewController {
    
    private let messageId: String
    private let viewModel = NMMailDetailViewModel()
    
    // MARK: - UI Components
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let web = WKWebView(frame: .zero, configuration: config)
        web.backgroundColor = .systemBackground
        web.isOpaque = false // 配合 CSS 适配深色模式
        return web
    }()
    
    // 简易的头部视图 (展示发件人、标题)
    // 实际开发中建议封装为单独的 View
    private lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Init
    
    init(messageId: String) {
        self.messageId = messageId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        // 开始加载
        viewModel.loadDetail(id: messageId)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 布局 (简单使用 StackView 或 Frame)
        view.addSubview(headerView)
        headerView.addSubview(subjectLabel)
        view.addSubview(webView)
        
        // 简单的 Layout (建议用 SnapKit)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            subjectLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            subjectLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            subjectLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            subjectLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            // WebView
            webView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        // 简单的闭包绑定或 Combine
        // 这里演示 Combine 方式的替代逻辑
        // 监听 htmlContent 变化...
        
        // 模拟 ViewModel 数据回调
        // 实际应使用 Combine: viewModel.$htmlContent.sink { ... }
        
        // 临时逻辑：当 loadDetail 完成后
        // 我们假设 ViewModel 有回调机制，或者简单地在这里轮询/Task等待
        // 为了演示完整性，我们在 loadDetail 内部直接更新 UI 也是一种简单的 MVVM 变体
        
        // 修改 ViewModel 增加回调：
        // viewModel.onDataUpdate = { [weak self] html in
        //    self?.webView.loadHTMLString(html, baseURL: nil)
        // }
    }
    
    // 补充：为了让上面的代码能跑，我们在 VM 加一个简单的 callback
    func updateContent(html: String) {
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func updateHeader(subject: String) {
        subjectLabel.text = subject
    }
}
