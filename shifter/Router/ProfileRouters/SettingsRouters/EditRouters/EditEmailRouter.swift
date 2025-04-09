import UIKit

// MARK: - Router

final class EditEmailRouter: EditEmailRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToPreviousScreen() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
