import UIKit

// MARK: - Router

final class CreateSetRouter: CreateSetRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToProfile(with user: User) {
        DispatchQueue.main.async {
            let profileVC = ProfileViewController(user: user)
            let navController = UINavigationController(rootViewController: profileVC)
            navController.modalPresentationStyle = .fullScreen
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
                window.makeKeyAndVisible()
            }
        }
    }
}
