import UIKit

protocol SignInRoutingLogic {
    func routeToForgotPassword()
    func routeToSignUp()
    func routeToProfile(with user: User)
}

final class SignInRouter: SignInRoutingLogic {
    weak var viewController: UIViewController?
    
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
