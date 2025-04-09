import Foundation

// MARK: - Presenter
final class SplashPresenter: SplashPresentationLogic {

    // MARK: - Properties
    weak var viewController: SplashDisplayLogic?

    // MARK: - Presentation Logic
    func presentInitialData(response: Splash.LoadInitialData.Response) {
        let destination: Splash.LoadInitialData.ViewModel.Destination = {
            if response.isUserLoggedIn, let user = response.user {
                return .profile(user)
            } else {
                return .signIn
            }
        }()
        
        let viewModel = Splash.LoadInitialData.ViewModel(destination: destination)
        viewController?.displayInitialData(viewModel: viewModel)
    }
}

