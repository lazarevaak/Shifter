import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Проверяем, залогинен ли пользователь (флаг устанавливается при успешном входе)
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        
        let rootVC: UIViewController
        if isUserLoggedIn, let user = SessionManager.shared.currentUser {
            // Если пользователь авторизован, открываем профиль
            rootVC = ProfileViewController(user: user)
        } else {
            // Иначе открываем экран входа
            rootVC = SignInViewController()
        }
        
        let navigationController = UINavigationController(rootViewController: rootVC)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}
