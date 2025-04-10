import UIKit

// MARK: - Router
final class AvatarSelectionRouter: AvatarSelectionRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}
