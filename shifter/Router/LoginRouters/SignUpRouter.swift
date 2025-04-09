import UIKit

// MARK: - Router

final class SignUpRouter: SignUpRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToSignIn() {
        if let navController = viewController?.navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
                viewController?.navigationController?.pushViewController(signInVC, animated: true)
            }
        }
    }
}
