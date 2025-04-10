import UIKit

// MARK: - Models
enum Splash {
    // MARK: Load Initial Data Models
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

// MARK: - Business Logic
protocol SplashBusinessLogic {
    func loadInitialData(request: Splash.LoadInitialData.Request)
}

// MARK: - Display Logic
protocol SplashDisplayLogic: AnyObject {
    func displayInitialData(viewModel: Splash.LoadInitialData.ViewModel)
}

// MARK: - Presentation Logic
protocol SplashPresentationLogic {
    func presentInitialData(response: Splash.LoadInitialData.Response)
}

// MARK: - Routing Logic
protocol SplashRoutingLogic {
    func routeToProfile(user: User)
    func routeToSignIn()
}

// MARK: - Data Passing
protocol SplashDataPassing {
    var dataStore: SplashDataStore? { get }
}

// MARK: - Data Store
protocol SplashDataStore {
    var isUserLoggedIn: Bool? { get set }
    var user: User? { get set }
}

// MARK: - Interactor
final class SplashInteractor: SplashBusinessLogic, SplashDataStore {
    var presenter: SplashPresentationLogic?
    
    // MARK: Data Store Properties
    var isUserLoggedIn: Bool?
    var user: User?

    // MARK: Load Initial Data
    func loadInitialData(request: Splash.LoadInitialData.Request) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Simulate loading delay
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

