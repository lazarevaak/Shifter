import UIKit

// MARK: - Router

final class ForgotPasswordRouter: ForgotPasswordRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToResetPassword(with email: String) {
        let resetVC = ResetPasswordViewController(email: email)
        viewController?.navigationController?.pushViewController(resetVC, animated: true)
    }
}
