import UIKit

public protocol NMCoordinator {
    var navigationController: NMBaseNavigationController { get set }
    func start()
}
