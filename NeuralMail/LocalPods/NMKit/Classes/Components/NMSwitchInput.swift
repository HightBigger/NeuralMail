//
//  NMSwitchInput.swift
//  NMAuthModule
//
//  Created by 小大 on 2025/12/23.
//

import UIKit
import SnapKit

public class NMSwitchInput: UIView {
    
    // 回调：开关状态改变
    public var onValueChange: ((Bool) -> Void)?
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    
    // 获取当前状态
    public var isOn: Bool {
        get { return toggleSwitch.isOn }
        set { toggleSwitch.setOn(newValue, animated: true) }
    }
    
    public init(title: String, icon: String, isOn: Bool = true) {
        super.init(frame: .zero)
        setupUI(title: title, icon: icon)
        self.isOn = isOn
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, icon: String) {
        // 1. 保持和 NMTextField 一样的外观
        self.backgroundColor = UIColor.secondarySystemBackground // NMColor.backgroundInput
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        // 2. 图标
        iconImageView.tintColor = .systemGray
        if let image = UIImage(systemName: icon) {
            iconImageView.image = image
        }
        
        // 3. 标题
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        // 4. 开关
        toggleSwitch.onTintColor = NMColor.actionPrimary // 品牌色
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        // 5. 布局
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(toggleSwitch)
        
        self.snp.makeConstraints { make in
            make.height.equalTo(52) // 和 NMTextField 高度一致
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        toggleSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func switchChanged() {
        onValueChange?(toggleSwitch.isOn)
    }
}
