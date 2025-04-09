import UIKit

// MARK: - Router

final class SplashRouter: SplashRoutingLogic, SplashDataPassing {

    // MARK: - Properties

    weak var viewController: SplashViewController?
    var dataStore: SplashDataStore?

    // MARK: - Routing Logic

    func routeToProfile(user: User) {
        let profileVC = ProfileViewController(user: user)
        let nav = UINavigationController(rootViewController: profileVC)
        performRootTransition(to: nav)
    }

    func routeToSignIn() {
        let signInVC = SignInViewController()
        let nav = UINavigationController(rootViewController: signInVC)
        performRootTransition(to: nav)
    }

    // MARK: - Navigation Helpers

    private func performRootTransition(to rootVC: UIViewController) {
        guard let window = viewController?.window else { return }
        window.rootViewController = rootVC
        window.makeKeyAndVisible()

        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3
        window.layer.add(transition, forKey: kCATransition)
    }
}
