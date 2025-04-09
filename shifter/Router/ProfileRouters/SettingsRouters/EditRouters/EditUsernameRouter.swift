import UIKit

// MARK: - Router

final class EditUsernameRouter: EditUsernameRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToPreviousScreen() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
