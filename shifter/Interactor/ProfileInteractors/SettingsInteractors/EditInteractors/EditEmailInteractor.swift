import UIKit

// MARK: - Models

enum EditEmailModels {
    enum UpdateEmail {
        struct Request {
            let newEmail: String
        }
        struct Response {
            let success: Bool
            let errorMessage: String?
        }
        struct ViewModel {
            let success: Bool
            let message: String
        }
    }
}

// MARK: - Protocols

// MARK: - Business Logic

protocol EditEmailBusinessLogic {
    func updateEmail(request: EditEmailModels.UpdateEmail.Request)
}

// MARK: - Routing Logic

protocol EditEmailRoutingLogic {
    func routeToPreviousScreen()
}

// MARK: - Presentation Logic

protocol EditEmailPresentationLogic {
    func presentUpdateEmail(response: EditEmailModels.UpdateEmail.Response)
}

// MARK: - Delegate

protocol EditEmailDelegate: AnyObject {
    func didUpdateEmail(_ newEmail: String)
}

// MARK: - Display Logic

protocol EditEmailDisplayLogic: AnyObject {
    func displayUpdateEmail(viewModel: EditEmailModels.UpdateEmail.ViewModel)
}

// MARK: - Interactor

final class EditEmailInteractor: EditEmailBusinessLogic {

    // MARK: - Properties

    var presenter: EditEmailPresentationLogic?
    var userId: String
    var currentEmail: String

    // MARK: - Initialization

    init(userId: String, currentEmail: String) {
        self.userId = userId
        self.currentEmail = currentEmail
    }

    // MARK: - Business Logic

    func updateEmail(request: EditEmailModels.UpdateEmail.Request) {
        let newEmail = request.newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !newEmail.isEmpty else {
            let response = EditEmailModels.UpdateEmail.Response(
                success: false,
                errorMessage: "please_enter_new_email".localized
            )
            presenter?.presentUpdateEmail(response: response)
            return
        }

        UserDataManager.shared.userExists(withEmail: newEmail, excludingUserId: userId) { [weak self] exists in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if exists {
                    let response = EditEmailModels.UpdateEmail.Response(
                        success: false,
                        errorMessage: "email_exists_error".localized
                    )
                    self.presenter?.presentUpdateEmail(response: response)
                } else {
                    UserDataManager.shared.updateEmail(for: self.userId, newEmail: newEmail) { success in
                        DispatchQueue.main.async {
                            if success {
                                UserDefaults.standard.set(newEmail, forKey: "LoggedInUserEmail")
                                let response = EditEmailModels.UpdateEmail.Response(
                                    success: true,
                                    errorMessage: nil
                                )
                                self.presenter?.presentUpdateEmail(response: response)
                            } else {
                                let response = EditEmailModels.UpdateEmail.Response(
                                    success: false,
                                    errorMessage: "update_email_failed".localized
                                )
                                self.presenter?.presentUpdateEmail(response: response)
                            }
                        }
                    }
                }
            }
        }
    }
}
