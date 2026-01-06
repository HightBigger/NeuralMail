import UIKit
import SnapKit
import NMKit
import NMModular
import FDFullscreenPopGesture

public class NMLoginViewController: NMViewController {
    
    private let defaultEmail: String?
    private var supportedDomains: [String] = []
    
    @NMLogger("NMAuthModule") var logger
    
    // 支持从路由传参初始化
    init(defaultEmail: String? = nil) {
        self.defaultEmail = defaultEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loadEmailConfig() // 加载配置
        setupAutoCompleteLogic() // 绑定逻辑
    }
    
    public override func setupLocalizedStrings() {
        super.setupLocalizedStrings()
        
        subtitleLabel.text = "login_subtitle".auth_localized
        emailLabel.text = "login_email_label".auth_localized
        passwordLabel.text = "login_password_label".auth_localized
        
        // NMTextField 内部代理了 placeholder 属性
        emailTextField.placeholder = "login_email_placeholder".auth_localized
        passwordTextField.placeholder = "login_password_placeholder".auth_localized
        
        nextButton.setTitle("login_next_button".auth_localized, for: .normal)
        footerLabel.text = "login_footer".auth_localized
    }
    
    // MARK: - Setup
    public override func setupUI() {
        
        // 不显示导航栏
        self.fd_prefersNavigationBarHidden = true
        // 禁用侧滑
        self.fd_interactivePopDisabled = true
        
        view.backgroundColor = NMColor.backgroundApp
        
        view.addSubview(globeButton)
        view.addSubview(containerView)
        
        containerView.addSubview(logoImageView)
        containerView.addSubview(appNameLabel)
        containerView.addSubview(subtitleLabel)
        
        containerView.addSubview(emailLabel)
        containerView.addSubview(emailTextField)
        containerView.addSubview(autoCompleteDropdown)
        
        containerView.addSubview(passwordLabel)
        containerView.addSubview(passwordTextField)
        
        containerView.addSubview(nextButton)
        containerView.addSubview(footerSeparator)
        containerView.addSubview(footerLabel)
        containerView.addSubview(versionLabel)
        
        // Layout
        globeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalToSuperview().inset(24)
            make.size.equalTo(25)
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            // 高度自适应，或者给一个 bottom 约束
            make.bottom.equalTo(footerLabel.snp.bottom).offset(24)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(48)
            make.leading.equalToSuperview().offset(32)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(56)
        }
        
        autoCompleteDropdown.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(4) // 留一点间隙
            make.leading.trailing.equalTo(emailTextField)
            make.height.equalTo(0) // 初始高度为0，由内容撑开
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(32)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(56)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(56)
        }
        
        footerSeparator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(footerLabel.snp.top).offset(-16)
            make.height.equalTo(1)
        }
        
        footerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(32)
            make.top.equalTo(nextButton.snp.bottom).offset(32)
            make.bottom.equalToSuperview().inset(24)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(32)
            make.centerY.equalTo(footerLabel)
        }
        
        containerView.bringSubviewToFront(autoCompleteDropdown)
    }
    
    // MARK: - Logic
    private func loadEmailConfig() {
        self.supportedDomains = NMEmailConfigLoader.shared.allDomains
    }
    
    private func setupAutoCompleteLogic() {
        emailTextField.onTextChange = { [weak self] text in
            self?.handleEmailInput(text)
        }
    }
    
    private func handleEmailInput(_ text: String) {
        guard !text.isEmpty else {
            autoCompleteDropdown.updateData([])
            return
        }
        
        var suggestions: [String] = []
        
        // 逻辑 A: 用户还没输入 @，显示常用邮箱建议
        if !text.contains("@") {
            suggestions = supportedDomains.map { "\(text)@\($0)" }
        }
        // 逻辑 B: 用户已经输入了 @，进行模糊匹配
        else {
            let components = text.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false)
            if components.count == 2 {
                let prefix = String(components[0]) // 用户名
                let domainPart = String(components[1]).lowercased() // 域名部分
                
                // 过滤匹配的域名
                let matchedDomains = supportedDomains.filter { $0.starts(with: domainPart) }
                suggestions = matchedDomains.map { "\(prefix)@\($0)" }
            }
        }
        
        // 更新 UI
        autoCompleteDropdown.updateData(suggestions)
    }
    
    // MARK: - Actions
    
    @objc private func didTapNext() {
        guard let email = emailTextField.text, !email.isEmpty else {
            logger.warn("Email field is empty")
            NMHUD.showToast(type: .warning, body: "Email field is empty")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            logger.warn("Password field is empty")
            NMHUD.showToast(type: .warning, body: "Password field is empty")
            return
        }
        
        logger.info("Login attempt - Email: \(email)")
        
        // 初始化配置页        
        let vm = NMManualConfigViewModel(
            email: email,
            password: password
        )
    
        let configVC = NMManualConfigViewController(viewModel: vm)
            
        configVC.modalPresentationStyle = .fullScreen
        present(configVC, animated: true)
    }
    
    private func handleLanguageSetting() {
        guard let vc = NMRouter.shared.match(url: "/preference/language") else {
            logger.error("未获取到语言选择界面")
            return
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = NMColor.backgroundCard
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = NMColor.borderInput.withAlphaComponent(0.1).cgColor
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemPurple
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        let text = NSMutableAttributedString(string: "Neural", attributes: [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: NMColor.textPrimary
        ])
        text.append(NSAttributedString(string: "Mail", attributes: [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: NMColor.textBrand
        ]))
        label.attributedText = text
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = NMColor.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = NMColor.textSecondary
        return label
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = NMColor.textSecondary
        return label
    }()
    
    // ✅ 新的邮箱输入框 ( NMTextField )
    private lazy var emailTextField: NMTextField = {
        // 直接在 Init 中传入图标
        let field = NMTextField(placeholder: "name@company.com", icon: "envelope")
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocapitalizationType = .none
        field.textContentType = .username // 自动填充
        field.text = defaultEmail
        field.delegate = self
        return field
    }()
    
    // ✅ 新的密码输入框 ( NMTextField )
    private lazy var passwordTextField: NMTextField = {
        let field = NMTextField(placeholder: "请输入密码", icon: "lock")
        field.returnKeyType = .done
        field.autocapitalizationType = .none
        field.textContentType = .password // 自动填充密码
        field.delegate = self
        field.enablePasswordToggle() // 🔥 开启小眼睛
        return field
    }()
    
    // ... (GlobeButton, NextButton, Footer 等保持不变) ...
    private lazy var globeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .light)
        button.setImage(UIImage(systemName: "globe", withConfiguration: config), for: .normal)
        button.tintColor = NMColor.textSecondary
        button.addAction(UIAction { [weak self] _ in
            self?.handleLanguageSetting()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = NMColor.actionPrimary
        button.layer.cornerRadius = 28
        button.setTitleColor(NMColor.textOnButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: "arrow.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = NMColor.textOnButton
        button.semanticContentAttribute = .forceRightToLeft
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapNext()
        }, for: .touchUpInside)
        return button
    }()
    
    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = NMColor.textSecondary
        return label
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.text = "V1.1.0"
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = NMColor.textSecondary
        return label
    }()
    
    private lazy var footerSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = NMColor.borderInput.withAlphaComponent(0.1)
        return view
    }()
    
    // ✅ 下拉列表组件
    private lazy var autoCompleteDropdown: NMAutoCompleteDropdown = {
        let dropdown = NMAutoCompleteDropdown()
        dropdown.onSelect = { [weak self] fullEmail in
            self?.emailTextField.text = fullEmail
            // 选中后自动跳到密码框
            self?.passwordTextField.becomeFirstResponder()
        }
        return dropdown
    }()
}

// MARK: - UITextFieldDelegate
extension NMLoginViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField.isDescendant(of: emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else if textField.isDescendant(of: passwordTextField) {
            textField.resignFirstResponder()
            didTapNext()
        }
        return true
    }
}
