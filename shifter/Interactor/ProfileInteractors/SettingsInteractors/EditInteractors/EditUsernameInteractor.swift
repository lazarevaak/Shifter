import Foundation

// MARK: - Models

enum EditUsernameModels {
    enum UpdateUsername {
        struct Request {
            let newName: String
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

// MARK: - Business Logic

protocol EditUsernameBusinessLogic {
    func updateUsername(request: EditUsernameModels.UpdateUsername.Request)
}

// MARK: - Routing Logic

protocol EditUsernameRoutingLogic {
    func routeToPreviousScreen()
}

// MARK: - Presentation Logic

protocol EditUsernamePresentationLogic {
    func presentUpdateUsername(response: EditUsernameModels.UpdateUsername.Response)
}

// MARK: - Delegate

protocol EditUsernameDelegate: AnyObject {
    func didUpdateUsername(_ newUsername: String)
}

// MARK: - Display Logic

protocol EditUsernameDisplayLogic: AnyObject {
    func displayUpdateUsername(viewModel: EditUsernameModels.UpdateUsername.ViewModel)
}

// MARK: - Interactor

final class EditUsernameInteractor: EditUsernameBusinessLogic {

    // MARK: - Properties

    var presenter: EditUsernamePresentationLogic?
    private let userId: String
    private let currentUsername: String

    // MARK: - Initialization

    init(userId: String, currentUsername: String) {
        self.userId = userId
        self.currentUsername = currentUsername
    }

    // MARK: - Business Logic

    func updateUsername(request: EditUsernameModels.UpdateUsername.Request) {
        UserDataManager.shared.updateUsername(for: userId, newName: request.newName) { [weak self] success in
            guard let self = self else { return }

            let response = EditUsernameModels.UpdateUsername.Response(
                success: success,
                message: success ? "username_update_success".localized : "username_update_failed".localized
            )

            DispatchQueue.main.async {
                self.presenter?.presentUpdateUsername(response: response)
            }
        }
    }
}
