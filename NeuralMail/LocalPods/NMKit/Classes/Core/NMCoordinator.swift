import UIKit

public protocol NMCoordinator {
    var navigationController: NMNavigationController { get set }
    func start()
}
