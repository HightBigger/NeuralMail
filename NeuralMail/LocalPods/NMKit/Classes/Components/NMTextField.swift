//
//  NMTextField.swift
//  Alamofire
//
//  Created by 小大 on 2025/12/17.
//

import UIKit
import SnapKit

public class NMTextField: UIView {
    
    public var onTextChange: ((String) -> Void)?
    // MARK: - UI Components
    
    private let internalTextField = UITextField()
    private let iconImageView = UIImageView()
    private let rightStackView = UIStackView()
    
    // 自定义清除按钮
    private lazy var clearButton: UIButton = {
        let btn = UIButton(type: .custom)
        // 使用 SF Symbol，配置颜色适配
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        // 设置颜色：平时为浅灰，不那么突兀
        btn.tintColor = UIColor.systemGray3
        btn.addTarget(self, action: #selector(handleClearText), for: .touchUpInside)
        btn.isHidden = true // 默认隐藏
        return btn
    }()
    
    private var eyeButton: UIButton?
    
    // MARK: - Properties
    
    public var text: String? {
        get { return internalTextField.text }
        set {
            internalTextField.text = newValue
            updateClearButtonVisibility() // 手动赋值也要更新按钮状态
        }
    }
    
    public var placeholder: String? {
        get { return internalTextField.placeholder }
        set { internalTextField.placeholder = newValue }
    }
    
    public var delegate: UITextFieldDelegate? {
        get { return internalTextField.delegate }
        set { internalTextField.delegate = newValue }
    }
    
    // 透传属性
    public var keyboardType: UIKeyboardType {
        get { return internalTextField.keyboardType }
        set { internalTextField.keyboardType = newValue }
    }
    
    public var returnKeyType: UIReturnKeyType {
        get { return internalTextField.returnKeyType }
        set { internalTextField.returnKeyType = newValue }
    }
    
    public var textContentType: UITextContentType! {
        get { return internalTextField.textContentType }
        set { internalTextField.textContentType = newValue }
    }
    
    public var isSecureTextEntry: Bool {
        get { return internalTextField.isSecureTextEntry }
        set { internalTextField.isSecureTextEntry = newValue }
    }
    
    public var autocapitalizationType: UITextAutocapitalizationType {
        get { return internalTextField.autocapitalizationType }
        set { internalTextField.autocapitalizationType = newValue }
    }
    
    // MARK: - Init
    
    public init(placeholder: String? = nil, icon: String? = nil) {
        super.init(frame: .zero)
        setupUI()
        self.placeholder = placeholder
        if let iconName = icon {
            setIcon(named: iconName)
        } else {
            updateLayoutForNoIcon()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateLayoutForNoIcon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        updateLayoutForNoIcon()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        self.backgroundColor = UIColor.secondarySystemBackground
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemGray
        
        internalTextField.font = UIFont.systemFont(ofSize: 16)
        internalTextField.textColor = .label
        
        // 🔥 关键点 1：禁用原生清除按钮
        internalTextField.clearButtonMode = .never
        
        // 🔥 关键点 2：监听文字变化，控制自定义按钮
        internalTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        internalTextField.addTarget(self, action: #selector(textDidBeginEditing), for: .editingDidBegin)
        internalTextField.addTarget(self, action: #selector(textDidEndEditing), for: .editingDidEnd)
        
        rightStackView.axis = .horizontal
        rightStackView.alignment = .center
        rightStackView.spacing = 8
        
        // 将清除按钮加入右侧 StackView
        // 注意：清除按钮应该在最左边（如果有眼睛按钮的话，清除按钮在眼睛左边）
        rightStackView.addArrangedSubview(clearButton)
        
        clearButton.snp.makeConstraints { make in
            make.size.equalTo(20) // 控制按钮大小
        }
        
        addSubview(iconImageView)
        addSubview(internalTextField)
        addSubview(rightStackView)
        
        // SnapKit Layout
        self.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        internalTextField.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalTo(rightStackView.snp.leading).offset(-8)
            make.top.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Logic & Actions
    
    /// 监听文字输入变化
    @objc private func textDidChange() {
        updateClearButtonVisibility()
        // 将最新的文本传给外部
        onTextChange?(internalTextField.text ?? "")
    }
    
    @objc private func textDidBeginEditing() {
        updateClearButtonVisibility()
    }
    
    @objc private func textDidEndEditing() {
        // 失去焦点时通常隐藏清除按钮
        clearButton.isHidden = true
    }
    
    /// 点击清除按钮
    @objc private func handleClearText() {
        internalTextField.text = ""
        // 触发 editingChanged 事件，通知外部监听者
        internalTextField.sendActions(for: .editingChanged)
        updateClearButtonVisibility()
    }
    
    /// 更新按钮显隐逻辑
    private func updateClearButtonVisibility() {
        // 只有当有内容且正在编辑时，才显示清除按钮
        let hasText = !(internalTextField.text?.isEmpty ?? true)
        let isEditing = internalTextField.isEditing
        // 如果是密码框，通常不显示清除按钮，或者根据需求决定
        // 这里假设密码框开启了 toggle 就不显示清除，避免太拥挤
        let shouldShow = hasText && isEditing && !internalTextField.isSecureTextEntry
        
        clearButton.isHidden = !shouldShow
    }
    
    // MARK: - Layout Helpers
    
    public func setIcon(named: String) {
        if let image = UIImage(systemName: named) {
            iconImageView.image = image
        } else {
            iconImageView.image = UIImage(named: named)
        }
        iconImageView.isHidden = false
        iconImageView.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(24)
        }
        internalTextField.snp.updateConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
        }
    }
    
    private func updateLayoutForNoIcon() {
        iconImageView.isHidden = true
        iconImageView.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(0)
        }
        internalTextField.snp.updateConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(0)
        }
    }
    
    // MARK: - Password Toggle
    
    public func enablePasswordToggle() {
        guard eyeButton == nil else { return }
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(handlePasswordToggle), for: .touchUpInside)
        
        button.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        // 眼睛按钮加在 StackView 的末尾
        rightStackView.addArrangedSubview(button)
        self.eyeButton = button
        
        internalTextField.isSecureTextEntry = true
        // 密码模式下绝对禁用清除按钮
        clearButton.isHidden = true
    }
    
    @objc private func handlePasswordToggle(_ sender: UIButton) {
        sender.isSelected.toggle()
        internalTextField.isSecureTextEntry = !sender.isSelected
        
        if let text = internalTextField.text {
            internalTextField.text = ""
            internalTextField.text = text
        }
    }
    
    // MARK: - Responder Chain
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        return internalTextField.becomeFirstResponder()
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        return internalTextField.resignFirstResponder()
    }
}
