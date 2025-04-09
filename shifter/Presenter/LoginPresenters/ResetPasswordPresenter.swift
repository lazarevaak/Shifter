import UIKit

// MARK: - Presenter

final class ResetPasswordPresenter: ResetPasswordPresentationLogic {

    // MARK: - Properties

    weak var viewController: ResetPasswordDisplayLogic?

    // MARK: - Presentation Logic

    func presentResetPassword(response: ResetPassword.Response) {
        let message = response.success ? "password_success_update_message".localized : (response.errorMessage ?? "password_update_error_message".localized)
        let viewModel = ResetPassword.ViewModel(message: message, success: response.success)
        viewController?.displayResetPassword(viewModel: viewModel)
    }
}
