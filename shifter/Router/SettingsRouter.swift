import UIKit

protocol SettingsRoutingLogic: AnyObject {
    func routeToPreviousScreen()
    func routeToSignIn()
}

final class SettingsRouter: SettingsRoutingLogic {
    weak var viewController: UIViewController?
    
    func routeToPreviousScreen() {
        if let navigationController = viewController?.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func routeToSignIn() {
        print("routeToSignIn called")
        SessionManager.shared.signOut()
        
        let signInVC = SignInViewController()
        let navController = UINavigationController(rootViewController: signInVC)
        navController.modalPresentationStyle = .fullScreen
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("Не удалось найти активное окно")
            return
        }
        
        print("Changing rootViewController to SignInViewController")
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}
