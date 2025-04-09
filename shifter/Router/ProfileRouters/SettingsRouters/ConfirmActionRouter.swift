import UIKit

// MARK: - Router

final class ConfirmActionRouter: ConfirmActionRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToPreviousScreen() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
