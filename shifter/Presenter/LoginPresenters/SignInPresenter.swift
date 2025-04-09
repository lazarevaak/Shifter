import UIKit

// MARK: - Presenter

final class SignInPresenter: SignInPresentationLogic {

    // MARK: - Properties

    weak var viewController: SignInDisplayLogic?

    // MARK: - Presentation Logic

    func presentSignIn(response: SignIn.Response) {
        if response.success {
            let message = "welcome_message".localized
            let viewModel = SignIn.ViewModel(message: message, user: response.user)
            viewController?.displaySignIn(viewModel: viewModel)
        } else {
            let message = response.errorMessage ?? "error_occurred_message".localized
            let viewModel = SignIn.ViewModel(message: message, user: nil)
            viewController?.displaySignIn(viewModel: viewModel)
        }
    }
}
