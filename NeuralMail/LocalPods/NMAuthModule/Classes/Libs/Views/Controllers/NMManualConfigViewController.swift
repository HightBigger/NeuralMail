//
//  NMManualConfigViewController.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/22.
//

import UIKit
import SnapKit
import NMKit
import NMModular
import Combine // 必须引入 Combine

public class NMManualConfigViewController: NMViewController {
    
    @NMLogger("NMAuthModule") var logger
    
    // MARK: - Properties
    
    // ✅ 1. 持有 ViewModel (非可选，由外部注入)
    private let viewModel: NMManualConfigViewModel
    
    // ✅ 2. 存放 Combine 订阅
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components (Scrollable)
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = NMColor.backgroundCard
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = NMColor.borderInput.withAlphaComponent(0.1).cgColor
        return view
    }()
    
    // --- Header ---
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = NMColor.textPrimary
        label.text = "config_title".auth_localized
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = NMColor.textSecondary
        label.text = "config_subtitle".auth_localized
        return label
    }()
    
    private lazy var protocolSegment: UISegmentedControl = {
        let items = ["IMAP", "POP3", "Exchange"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleProtocolChange), for: .valueChanged)
        return sc
    }()
    
    // --- Incoming ---
    private lazy var incomingHeader = createSectionHeader(text: "config_incoming_label".auth_localized)
    
    private lazy var incomingHostField: NMTextField = {
        let field = NMTextField(placeholder: "config_incoming_placeholder".auth_localized, icon: "server.rack")
        field.keyboardType = .URL
        field.returnKeyType = .next
        field.autocapitalizationType = .none
        field.layer.cornerRadius = 24
        field.layer.borderWidth = 1
        field.layer.borderColor = NMColor.borderInput.withAlphaComponent(0.1).cgColor
        field.delegate = self
        return field
    }()
    
    private lazy var incomingPortField: NMTextField = {
        let field = NMTextField(placeholder: "config_port_placeholder".auth_localized, icon: "number")
        field.keyboardType = .numberPad
        field.text = "993"
        field.layer.cornerRadius = 24
        field.layer.borderWidth = 1
        field.layer.borderColor = NMColor.borderInput.withAlphaComponent(0.1).cgColor
        field.delegate = self
        field.returnKeyType = .next
        return field
    }()
    
    private lazy var incomingSSLSwitch: NMSwitchInput = {
        let view = NMSwitchInput(title: "SSL", icon: "lock.shield", isOn: true)
        view.onValueChange = { [weak self] isOn in
            // UI -> VM
            self?.viewModel.toggleIncomingSSL(isOn)
        }
        return view
    }()
    
    // --- Outgoing ---
    private lazy var outgoingHeader = createSectionHeader(text: "config_outgoing_label".auth_localized)
    
    private lazy var outgoingHostField: NMTextField = {
        let field = NMTextField(placeholder: "config_outgoing_placeholder".auth_localized, icon: "paperplane")
        field.keyboardType = .URL
        field.returnKeyType = .next
        field.delegate = self
        field.autocapitalizationType = .none
        field.layer.cornerRadius = 24
        field.layer.borderWidth = 1
        field.layer.borderColor = NMColor.borderInput.withAlphaComponent(0.1).cgColor
        return field
    }()
    
    private lazy var outgoingPortField: NMTextField = {
        let field = NMTextField(placeholder: "config_port_placeholder".auth_localized, icon: "number")
        field.keyboardType = .numberPad
        field.delegate = self
        field.text = "465"
        field.layer.cornerRadius = 24
        field.layer.borderWidth = 1
        field.layer.borderColor = NMColor.borderInput.withAlphaComponent(0.1).cgColor
        return field
    }()
    
    private lazy var outgoingSSLSwitch: NMSwitchInput = {
        let view = NMSwitchInput(title: "SSL", icon: "lock.shield", isOn: true)
        view.onValueChange = { [weak self] isOn in
            // UI -> VM
            self?.viewModel.toggleOutgoingSSL(isOn)
        }
        return view
    }()
    
    // --- Actions ---
    private lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("config_login_button".auth_localized, for: .normal)
        btn.backgroundColor = NMColor.actionPrimary
        btn.setTitleColor(NMColor.textOnButton, for: .normal)
        btn.layer.cornerRadius = 25
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        return btn
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        button.tintColor = NMColor.textSecondary
        button.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        button.layer.cornerRadius = 16
        button.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init (依赖注入)
    
    public init(viewModel: NMManualConfigViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupInputObservation()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
                
        // Incoming Host
        viewModel.$incomingHost
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.incomingHostField.text = text
            }
            .store(in: &cancellables)
            
        // Incoming Port
        viewModel.$incomingPort
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.incomingPortField.text = text
            }
            .store(in: &cancellables)
            
        // SSL Switch
        viewModel.$isIncomingSSL
            .receive(on: RunLoop.main)
            .sink { [weak self] isOn in
                if self?.incomingSSLSwitch.isOn != isOn {
                    self?.incomingSSLSwitch.isOn = isOn
                }
            }
            .store(in: &cancellables)
            
        // Outgoing Host
        viewModel.$outgoingHost
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.outgoingHostField.text = text
            }
            .store(in: &cancellables)
            
        // Outgoing Port
        viewModel.$outgoingPort
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.outgoingPortField.text = text
            }
            .store(in: &cancellables)
            
        viewModel.$isOutgoingSSL
            .receive(on: RunLoop.main)
            .sink { [weak self] isOn in
                if self?.outgoingSSLSwitch.isOn != isOn {
                    self?.outgoingSSLSwitch.isOn = isOn
                }
            }
            .store(in: &cancellables)
            
        // Loading State
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { isLoading in
                if isLoading {
                    NMHUD.showLoading()
                } else {
                    NMHUD.dismiss()
                }
            }
            .store(in: &cancellables)
            
        // Error State
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .compactMap { $0 } // 过滤 nil
            .sink { errorMsg in
                NMHUD.showToast(type: .error, body: errorMsg)
            }
            .store(in: &cancellables)
            
        // Success State
        viewModel.$isLoginSuccess
            .receive(on: RunLoop.main)
            .filter { $0 }
            .sink { [weak self] _ in
                // 登录成功，关闭页面
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    
    private func setupInputObservation() {
        // ✅ 使用通知中心监听所有 UITextField 的输入变化
        // 因为 NMTextField 内部包裹了 UITextField，这种方式能穿透 wrapper 直接监听到
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextFieldChange(_:)),
            name: UITextField.textDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleTextFieldChange(_ notification: Notification) {
        guard let textField = notification.object as? UITextField else { return }
        
        // ✅ 使用 isDescendant 判断是哪个 NMTextField 的子视图
        if textField.isDescendant(of: incomingHostField) {
            viewModel.incomingHost = incomingHostField.text ?? ""
        } else if textField.isDescendant(of: incomingPortField) {
            viewModel.incomingPort = incomingPortField.text ?? ""
        } else if textField.isDescendant(of: outgoingHostField) {
            viewModel.outgoingHost = outgoingHostField.text ?? ""
        } else if textField.isDescendant(of: outgoingPortField) {
            viewModel.outgoingPort = outgoingPortField.text ?? ""
        }
    }
    
    // MARK: - Actions (Input)
    
    @objc private func handleProtocolChange() {
        if let type = NMManualConfigViewModel.ProtocolType(rawValue: protocolSegment.selectedSegmentIndex) {
            viewModel.updateProtocol(type)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        // 双向绑定：将 UI 变化同步回 VM
        if textField == incomingHostField {
            viewModel.incomingHost = text
        } else if textField == incomingPortField {
            viewModel.incomingPort = text
        } else if textField == outgoingHostField {
            viewModel.outgoingHost = text
        } else if textField == outgoingPortField {
            viewModel.outgoingPort = text
        }
    }
    
    @objc private func didTapLogin() {
        // UI 收起键盘
        view.endEditing(true)
        // 命令 VM 执行登录
        viewModel.login()
    }
    
    // MARK: - UI Setup
    public override func setupUI() {
        view.backgroundColor = NMColor.backgroundApp
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        contentView.addSubview(protocolSegment)
        
        contentView.addSubview(incomingHeader)
        contentView.addSubview(incomingHostField)
        contentView.addSubview(incomingPortField)
        contentView.addSubview(incomingSSLSwitch)
        
        contentView.addSubview(outgoingHeader)
        contentView.addSubview(outgoingHostField)
        contentView.addSubview(outgoingPortField)
        contentView.addSubview(outgoingSSLSwitch)
        
        contentView.addSubview(loginButton)
        
        setupConstraints()
    }
    

    private func setupConstraints() {
       
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
        }
        backButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(24)
            make.size.equalTo(32)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(16)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel)
        }
        protocolSegment.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(32)
        }
        incomingHeader.snp.makeConstraints { make in
            make.top.equalTo(protocolSegment.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
        }
        incomingHostField.snp.makeConstraints { make in
            make.top.equalTo(incomingHeader.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        incomingPortField.snp.makeConstraints { make in
            make.top.equalTo(incomingHostField.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(contentView).multipliedBy(0.35)
            make.height.equalTo(52)
        }
        incomingSSLSwitch.snp.makeConstraints { make in
            make.top.equalTo(incomingPortField)
            make.leading.equalTo(incomingPortField.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        outgoingHeader.snp.makeConstraints { make in
            make.top.equalTo(incomingPortField.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(24)
        }
        outgoingHostField.snp.makeConstraints { make in
            make.top.equalTo(outgoingHeader.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        outgoingPortField.snp.makeConstraints { make in
            make.top.equalTo(outgoingHostField.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.width.equalTo(contentView).multipliedBy(0.35)
            make.height.equalTo(52)
        }
        outgoingSSLSwitch.snp.makeConstraints { make in
            make.top.equalTo(outgoingPortField)
            make.leading.equalTo(outgoingPortField.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(outgoingPortField.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    
    private func createSectionHeader(text: String) -> UILabel {
        let label = UILabel()
        label.text = text.uppercased()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = NMColor.textSecondary
        label.letterSpacing = 1.0
        return label
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
}

// MARK: - UITextFieldDelegate

extension NMManualConfigViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isDescendant(of: incomingHostField) {
            incomingPortField.becomeFirstResponder()
        }
        else if textField.isDescendant(of: incomingPortField) {
            outgoingHostField.becomeFirstResponder()
        }
        else if textField.isDescendant(of: outgoingHostField) {
            outgoingPortField.becomeFirstResponder()
        }
        else if textField.isDescendant(of: outgoingPortField) {
            textField.resignFirstResponder()
            // 提交给 VM
            viewModel.login()
        }
        
        return true
    }
}

// Helper Extension for spacing
extension UILabel {
    var letterSpacing: CGFloat {
        set {
            let attributedString: NSMutableAttributedString
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            } else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                attributedString.addAttribute(.font, value: font as Any, range: NSRange(location: 0, length: attributedString.length))
                attributedString.addAttribute(.foregroundColor, value: textColor as Any, range: NSRange(location: 0, length: attributedString.length))
            }
            attributedString.addAttribute(.kern, value: newValue, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
        get {
            return 0
        }
    }
}
