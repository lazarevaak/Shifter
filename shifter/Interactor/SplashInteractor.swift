import UIKit
// MARK: - Models

enum Splash {
    enum LoadInitialData {
        struct Request { }
        struct Response {
            let isUserLoggedIn: Bool
            let user: User?
        }
        struct ViewModel {
            enum Destination {
                case profile(User)
                case signIn
            }
            let destination: Destination
        }
    }
}

// MARK: - Protocols

// Business Logic
protocol SplashBusinessLogic {
    func loadInitialData(request: Splash.LoadInitialData.Request)
}

// Display Logic
protocol SplashDisplayLogic: AnyObject {
    func displayInitialData(viewModel: Splash.LoadInitialData.ViewModel)
}

// Presentation Logic
protocol SplashPresentationLogic {
    func presentInitialData(response: Splash.LoadInitialData.Response)
}

// Routing
protocol SplashRoutingLogic {
    func routeToProfile(user: User)
    func routeToSignIn()
}
protocol SplashDataPassing {
    var dataStore: SplashDataStore? { get }
}
protocol SplashDataStore {
    var isUserLoggedIn: Bool? { get set }
    var user: User? { get set }
}

// MARK: - Interactor

final class SplashInteractor: SplashBusinessLogic, SplashDataStore {
    var presenter: SplashPresentationLogic?
    var isUserLoggedIn: Bool?
    var user: User?

    func loadInitialData(request: Splash.LoadInitialData.Request) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            Thread.sleep(forTimeInterval: 2)

            let loggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")

            DispatchQueue.main.async {
                let currentUser = loggedIn
                    ? SessionManager.shared.currentUser
                    : nil

                self?.isUserLoggedIn = loggedIn
                self?.user = currentUser

                let response = Splash.LoadInitialData.Response(
                    isUserLoggedIn: loggedIn,
                    user: currentUser
                )
                self?.presenter?.presentInitialData(response: response)
            }
        }
    }
}


