import UIKit

// MARK: - Router

final class ResetPasswordRouter: ResetPasswordRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToSignIn() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }
}
