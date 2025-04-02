import UIKit
import Foundation

final class ForgotPasswordPresenter: ForgotPasswordPresentationLogic {
    weak var viewController: ForgotPasswordDisplayLogic?
    
    func presentForgotPassword(response: ForgotPassword.Response) {
        let viewModel = ForgotPassword.ViewModel(message: response.message, success: response.success)
        viewController?.displayForgotPassword(viewModel: viewModel)
    }
}
