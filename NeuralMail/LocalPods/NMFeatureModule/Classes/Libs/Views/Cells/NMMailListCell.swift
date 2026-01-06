//
//  NMMailListCell.swift
//  NMFeatureModule
//
//  Created by 小大 on 2025/12/26.
//

import UIKit
import NMModular

class NMMailListCell: UITableViewCell {
    
    static let reuseIdentifier = "NMMailListCell"
    
    // MARK: - UI Components
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemGray5
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let senderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        return label
    }()
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let unreadIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 4
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Configuration
    
    func configure(with message: NMMailMessage) {
        senderLabel.text = message.sender
        subjectLabel.text = message.subject
        previewLabel.text = message.preview
        
        // 简单的时间格式化 (建议提取为工具类)
        let formatter = DateFormatter()
        formatter.dateFormat = Calendar.current.isDateInToday(message.date) ? "HH:mm" : "MM-dd"
        timeLabel.text = formatter.string(from: message.date)
        
        // 头像占位符 (取首字母)
        let initial = message.sender.prefix(1).uppercased()
        avatarLabel.text = initial.isEmpty ? "U" : initial
        
        // 已读/未读状态
        unreadIndicator.isHidden = message.isRead
        
        // 样式微调
        if !message.isRead {
            subjectLabel.font = .systemFont(ofSize: 15, weight: .bold)
            senderLabel.textColor = .label
        } else {
            subjectLabel.font = .systemFont(ofSize: 15, weight: .medium)
            senderLabel.textColor = .secondaryLabel
        }
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        contentView.addSubview(avatarLabel)
        contentView.addSubview(unreadIndicator)
        
        let headerStack = UIStackView(arrangedSubviews: [senderLabel, timeLabel])
        headerStack.axis = .horizontal
        headerStack.distribution = .fill
        headerStack.spacing = 8
        
        let contentStack = UIStackView(arrangedSubviews: [headerStack, subjectLabel, previewLabel])
        contentStack.axis = .vertical
        contentStack.spacing = 4
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            // Avatar
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarLabel.widthAnchor.constraint(equalToConstant: 40),
            avatarLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Unread Dot (在头像右上角)
            unreadIndicator.widthAnchor.constraint(equalToConstant: 8),
            unreadIndicator.heightAnchor.constraint(equalToConstant: 8),
            unreadIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            unreadIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            
            // Content Stack
            contentStack.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // Compression Resistance (防止时间被挤压)
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
    }
}
