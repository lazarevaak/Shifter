import UIKit

final class ForgotPasswordRouter: ForgotPasswordRoutingLogic {
    weak var viewController: UIViewController?
    
    func routeToResetPassword(with email: String) {
        let resetVC = ResetPasswordViewController(email: email)
        viewController?.navigationController?.pushViewController(resetVC, animated: true)
    }
}

