import UIKit
import SnapKit
import NMKit
import FDFullscreenPopGesture

public class NMSplashViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var logoLabel: UILabel = {
        let label = UILabel()
        label.text = "NeuralMail"
        label.font = .systemFont(ofSize: 40, weight: .heavy)
        label.textColor = NMColor.textBrand
        label.textAlignment = .center
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startLoading()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
        //不显示导航栏
        self.fd_prefersNavigationBarHidden = true
        //禁用侧滑
        self.fd_interactivePopDisabled = true
        
        view.backgroundColor = NMColor.backgroundApp
        
        view.addSubview(logoLabel)
        view.addSubview(activityIndicator)
        
        logoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.top.equalTo(logoLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Logic
    
    private func startLoading() {
        activityIndicator.startAnimating()
        
    }
}
