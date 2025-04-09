import UIKit

// MARK: - Router

final class SignInRouter: SignInRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    
    func routeToForgotPassword() {
        let forgotVC = ForgotPasswordViewController()
        viewController?.navigationController?.pushViewController(forgotVC, animated: true)
    }
    
    func routeToSignUp() {
        let signUpVC = SignUpViewController()
        viewController?.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func routeToProfile(with user: User) {
        SessionManager.shared.setLoggedInUser(user)
        let profileVC = ProfileViewController(user: user)
        viewController?.navigationController?.pushViewController(profileVC, animated: true)
    }
}
