import UIKit

// MARK: - Router

final class EditCardRouter: EditCardRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToPreviousScreen() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
