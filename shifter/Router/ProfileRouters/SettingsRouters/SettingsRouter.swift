import UIKit

// MARK: - Router

final class SettingsRouter: SettingsRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    
    func routeToPreviousScreen() {
        if let navigationController = viewController?.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func routeToSignIn() {
        SessionManager.shared.signOut()
        
        let signInVC = SignInViewController()
        let navController = UINavigationController(rootViewController: signInVC)
        navController.modalPresentationStyle = .fullScreen
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}
