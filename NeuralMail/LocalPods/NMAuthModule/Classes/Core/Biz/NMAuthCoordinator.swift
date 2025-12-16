import UIKit
import NMKit

public class NMAuthCoordinator: NMCoordinator {
    public var navigationController: NMBaseNavigationController
    
    public init(navigationController: NMBaseNavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let viewModel = NMLoginViewModel()
        let viewController = NMLoginViewController()
        navigationController.setViewControllers([viewController], animated: false)
    }
}
