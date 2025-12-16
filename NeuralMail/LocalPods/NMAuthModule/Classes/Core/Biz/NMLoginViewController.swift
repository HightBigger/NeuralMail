import UIKit
import SnapKit
import NMKit
import NMModular
import FDFullscreenPopGesture

public class NMLoginViewController: NMBaseViewController {
    
    private let defaultEmail: String?
    
    @NMLogger("Auth") var logger
    @NMInjected var authService: NMAuthService
    
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
        
    }
    
    public override func setupLocalizedStrings() {
        super.setupLocalizedStrings()
        
        subtitleLabel.text = "login_subtitle".auth_localized
        emailLabel.text = "login_email_label".auth_localized
        passwordLabel.text = "login_password_label".auth_localized
        
        let emailPlaceholderText = "login_email_placeholder".auth_localized
        let passwordPlaceholderText = "login_password_placeholder".auth_localized
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NMColor.textSecondary
        ]
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailPlaceholderText, attributes: placeholderAttributes)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordPlaceholderText, attributes: placeholderAttributes)
        
        nextButton.setTitle("login_next_button".auth_localized, for: .normal)
        manualConfigButton.setTitle("login_manual_config".auth_localized, for: .normal)
        footerLabel.text = "login_footer".auth_localized
    }
        
    // MARK: - Setup
    public override func setupUI() {
        
        //不显示导航栏
        self.fd_prefersNavigationBarHidden = true
        //禁用侧滑
        self.fd_interactivePopDisabled = true
        
        view.backgroundColor = NMColor.backgroundApp
        
        view.addSubview(globeButton)
        view.addSubview(containerView)
        
        containerView.addSubview(logoImageView)
        containerView.addSubview(appNameLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(emailLabel)
        containerView.addSubview(emailInputContainer)
        containerView.addSubview(passwordLabel)
        containerView.addSubview(passwordInputContainer)
        containerView.addSubview(nextButton)
        containerView.addSubview(manualConfigButton)
        containerView.addSubview(footerSeparator)
        containerView.addSubview(footerLabel)
        containerView.addSubview(versionLabel)
        
        emailInputContainer.addSubview(emailIconView)
        emailInputContainer.addSubview(emailTextField)
        passwordInputContainer.addSubview(passwordIconView)
        passwordInputContainer.addSubview(passwordTextField)
        
        // Layout
        globeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalToSuperview().inset(24)
            make.size.equalTo(25)
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
//            make.height.equalTo(600) 
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
        
        emailInputContainer.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(56)
        }
        
        emailIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.leading.equalTo(emailIconView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailInputContainer.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(32)
        }
        
        passwordInputContainer.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(56)
        }
        
        passwordIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.leading.equalTo(passwordIconView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        manualConfigButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(manualConfigButton.snp.bottom).offset(16)
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
    }
    
    // MARK: - Actions
    
    @objc private func didTapNext() {
        guard let email = emailTextField.text, !email.isEmpty else {
            logger.warn("Email field is empty")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            logger.warn("Password field is empty")
            return
        }
        
        logger.info("Login attempt - Email: \(email), Password: ***")
        // TODO: Trigger ViewModel action with email and password
    }
    
    private func handleLanguageSetting() {
                
        guard let vc = NMRouter.shared.match(url: "/preference/language") else {
            logger.error("未获取到语言选择界面")
            return
        }
        
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false)
    }
    
    // MARK: - UI Components
        
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = NMColor.backgroundApp
        // TODO: Add gradient background image if available
        return imageView
    }()
    
    private lazy var globeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .light)
        button.setImage(UIImage(systemName: "globe", withConfiguration: config), for: .normal)
        button.tintColor = NMColor.textSecondary
        // 添加点击事件（闭包方式）
        button.addAction(UIAction { [weak self] _ in
            self?.handleLanguageSetting()
        }, for: .touchUpInside)
        
        return button
    }()
    
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
        imageView.backgroundColor = .systemPurple // Placeholder for Logo
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        // TODO: Set actual logo image
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
    
    private lazy var emailInputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = NMColor.backgroundInput
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = NMColor.borderInput.cgColor
        return view
    }()
    
    private lazy var passwordInputContainer: UIView = {
        let view = UIView()
        view.backgroundColor = NMColor.backgroundInput
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = NMColor.borderInput.cgColor
        return view
    }()
    
    private lazy var emailIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "envelope")
        imageView.tintColor = NMColor.textSecondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var passwordIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "lock")
        imageView.tintColor = NMColor.textSecondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "name@company.com"
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = NMColor.textPrimary
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .next
        textField.text = defaultEmail
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NMColor.textSecondary
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "name@company.com", attributes: placeholderAttributes)
        
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入密码"
        textField.font = .systemFont(ofSize: 16)
        textField.textColor = NMColor.textPrimary
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NMColor.textSecondary
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "请输入密码", attributes: placeholderAttributes)
        
        return textField
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = NMColor.actionPrimary
        button.layer.cornerRadius = 28 // Half of 56 height
        button.setTitleColor(NMColor.textOnButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let image = UIImage(systemName: "arrow.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = NMColor.textOnButton
        
        // Layout for image on the right
        button.semanticContentAttribute = .forceRightToLeft
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapNext()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var manualConfigButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(NMColor.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        
        let config = UIImage.SymbolConfiguration(pointSize: 12)
        let image = UIImage(systemName: "slider.horizontal.3", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = NMColor.textSecondary
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        
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
}









