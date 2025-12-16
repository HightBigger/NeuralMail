import UIKit
import SnapKit
import NMKit
import NMModular

extension NMLanguage {
    
    public func displayName(language:NMLanguage)-> String {
        switch self {
        case .english: return "English"
        case .chineseSimplified: return "简体中文"
        case .chineseTraditional: return "繁體中文"
        case .system:
            switch language {
            case .english:
                return "Follow System"
            case .chineseTraditional:
                return "跟隨系統"
            default:
                return "跟随系统"
            }
        }
    }
    
    var subtitle : String {
        switch self {
        case .english: return "English"
        case .chineseSimplified: return "Simplified Chinese"
        case .chineseTraditional: return "Traditional Chinese"
        case .system: return "System Default"
        }
        
    }
}

class NMLanguageSelectionViewController: NMBaseViewController {

    @NMInjected var prefService: NMPreferenceService
    
    // Temporary selection state before confirmation
    private var selectedLanguage: NMLanguage?
    
    // MARK: - Data Models

    private let languages : [NMLanguage] = [
        NMLanguage.system,
        NMLanguage.chineseSimplified,
        NMLanguage.chineseTraditional,
        NMLanguage.english
    ]
        
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        // Use a very dark grey/black for the card background
        view.backgroundColor = NMColor.backgroundCard
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        button.tintColor = NMColor.textSecondary
        button.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        button.layer.cornerRadius = 16 // Circular 32x32?
        
        button.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = NMColor.textPrimary
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = NMColor.textSecondary
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(NMColor.textSecondary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        
        button.addAction(UIAction { [weak self] _ in
            self?.saveAndDismiss()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private var optionViews: [LanguageOptionView] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedLanguage = prefService.language
        
        // setupUI() // Removed as per instruction
        setupOptions()
    }
    
    override func setupLocalizedStrings() {
        super.setupLocalizedStrings()

        titleLabel.text = "language_select_title".pref_localized
        subtitleLabel.text = "language_select_subtitle".pref_localized
        confirmButton.setTitle("language_confirm_button".pref_localized, for: .normal)
    }
    
    // MARK: - Setup
    override func setupUI() {
        view.backgroundColor = NMColor.backgroundApp // Important for overFullScreen
        
        view.addSubview(containerView)
        
        containerView.addSubview(backButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(stackView)
        containerView.addSubview(confirmButton)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            // Height will be determined by content + padding, but we can also set constraints
            make.bottom.equalTo(confirmButton.snp.bottom).offset(24)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(24)
            make.size.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton) // Align with back button visually or top?
            // Design shows title to the right of back button
            make.leading.equalTo(backButton.snp.trailing).offset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            // Height calculated by content
        }
        
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    private func setupOptions() {
        for (index, language) in languages.enumerated() {
            let optionView = LanguageOptionView()
            optionView.configure(title: language.displayName(language: prefService.language), subtitle: language.subtitle)
            optionView.tag = index
            optionView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(didSelectOption(_:)))
            optionView.addGestureRecognizer(tap)
            
            // Initial Selection State
            let isSelected = language == selectedLanguage
            optionView.setSelected(isSelected)
            
            stackView.addArrangedSubview(optionView)
            optionViews.append(optionView)
            
            optionView.snp.makeConstraints { make in
                make.height.equalTo(64)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func didSelectOption(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view as? LanguageOptionView else { return }
        let index = view.tag
        let language = languages[index]
        
        selectedLanguage = language
        
        // Update UI
        for (i, optionView) in optionViews.enumerated() {
            optionView.setSelected(i == index)
        }
        
        // Feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func saveAndDismiss() {
        
        prefService.setLanguage(selectedLanguage!)
        
        UIView.animate(withDuration: 0.2) {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}

// MARK: - Custom View

class LanguageOptionView: UIView {
    
    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0 // Default none
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = NMColor.textPrimary
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = NMColor.textSecondary.withAlphaComponent(0.6)
        return label
    }()
    
    private lazy var checkmarkIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = NMColor.textBrand // Purple
        imageView.isHidden = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(checkmarkIcon)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
        }
        
        checkmarkIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(24)
        }
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            // Selected Style
            container.layer.borderWidth = 1.5
            container.layer.borderColor = NMColor.textBrand.cgColor // Purple Border
            container.backgroundColor = NMColor.textBrand.withAlphaComponent(0.1) // Slight purple tint BG
            checkmarkIcon.isHidden = false
        } else {
            // Unselected Style
            container.layer.borderWidth = 0
            container.backgroundColor = UIColor.white.withAlphaComponent(0.05) // Dark grey
            checkmarkIcon.isHidden = true
        }
    }
}
