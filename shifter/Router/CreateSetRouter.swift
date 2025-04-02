import UIKit

protocol CreateSetRoutingLogic {
    func routeToProfile(with user: User)
}

final class CreateSetRouter: CreateSetRoutingLogic {
    weak var viewController: UIViewController?
    
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
