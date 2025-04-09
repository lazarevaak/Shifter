import UIKit

// MARK: - Router

final class SetDetailsRouter: SetDetailsRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func dismiss() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
