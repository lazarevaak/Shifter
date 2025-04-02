import UIKit

enum ResetPassword {
    struct Request {
        let code: String
        let newPassword: String
        let email: String
    }
    struct Response {
        let success: Bool
        let errorMessage: String?
    }
    struct ViewModel {
        let message: String
        let success: Bool
    }
}

protocol ResetPasswordBusinessLogic {
    func resetPassword(request: ResetPassword.Request)
}

protocol ResetPasswordPresentationLogic {
    func presentResetPassword(response: ResetPassword.Response)
}

protocol ResetPasswordDisplayLogic: AnyObject {
    func displayResetPassword(viewModel: ResetPassword.ViewModel)
}

final class ResetPasswordPresenter: ResetPasswordPresentationLogic {
    weak var viewController: ResetPasswordDisplayLogic?
    
    func presentResetPassword(response: ResetPassword.Response) {
        let message = response.success ? "Пароль успешно обновлён!" : (response.errorMessage ?? "Ошибка обновления пароля.")
        let viewModel = ResetPassword.ViewModel(message: message, success: response.success)
        viewController?.displayResetPassword(viewModel: viewModel)
    }
}

