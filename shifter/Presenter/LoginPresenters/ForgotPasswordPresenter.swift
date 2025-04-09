import UIKit
import Foundation

// MARK: - Presenter

final class ForgotPasswordPresenter: ForgotPasswordPresentationLogic {

    // MARK: - Properties

    weak var viewController: ForgotPasswordDisplayLogic?

    // MARK: - Presentation Logic

    func presentForgotPassword(response: ForgotPassword.Response) {
        let viewModel = ForgotPassword.ViewModel(message: response.message, success: response.success)
        viewController?.displayForgotPassword(viewModel: viewModel)
    }
}
