import Foundation

// MARK: - Models

enum EditPasswordModels {
    enum UpdatePassword {
        struct Request {
            let newPassword: String
        }
        struct Response {
            let success: Bool
            let message: String?
        }
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
}

// MARK: - Protocols

// MARK: - Business Logic

protocol EditPasswordBusinessLogic {
    func updatePassword(request: EditPasswordModels.UpdatePassword.Request)
}

// MARK: - Routing Logic

protocol EditPasswordRoutingLogic {
    func routeToPreviousScreen()
}

// MARK: - Presentation Logic

protocol EditPasswordPresentationLogic {
    func presentUpdatePassword(response: EditPasswordModels.UpdatePassword.Response)
}

// MARK: - Display Logic

protocol EditPasswordDisplayLogic: AnyObject {
    func displayUpdatePassword(viewModel: EditPasswordModels.UpdatePassword.ViewModel)
}

// MARK: - Interactor

final class EditPasswordInteractor: EditPasswordBusinessLogic {

    // MARK: - Properties

    var presenter: EditPasswordPresentationLogic?
    private let userId: String
    private let currentPassword: String

    // MARK: - Initialization

    init(userId: String, currentPassword: String) {
        self.userId = userId
        self.currentPassword = currentPassword
    }

    // MARK: - Business Logic

    func updatePassword(request: EditPasswordModels.UpdatePassword.Request) {
        UserDataManager.shared.updatePassword(for: userId, newPassword: request.newPassword) { [weak self] success in
            guard let self = self else { return }

            let response = EditPasswordModels.UpdatePassword.Response(
                success: success,
                message: success ? "password_update_success".localized : "password_update_failed".localized
            )

            DispatchQueue.main.async {
                self.presenter?.presentUpdatePassword(response: response)
            }
        }
    }
}
