import UIKit

protocol ResetPasswordRoutingLogic {
    func routeToSignIn()
}

final class ResetPasswordRouter: ResetPasswordRoutingLogic {
    weak var viewController: UIViewController?
    
    func routeToSignIn() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }
}

