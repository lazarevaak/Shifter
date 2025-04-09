import UIKit

// MARK: - Presenter

final class SignUpPresenter: SignUpPresentationLogic {

    // MARK: - Properties

    weak var viewController: SignUpDisplayLogic?

    // MARK: - Presentation Logic

    func presentSignUp(response: SignUp.Response) {
        let message: String
        if response.success {
            message = "reg_success_message".localized
        } else {
            message = response.errorMessage ?? "reg_fail_message".localized
        }
        let viewModel = SignUp.ViewModel(message: message)
        viewController?.displaySignUp(viewModel: viewModel)
    }
}
