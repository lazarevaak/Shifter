import UIKit

// MARK: - Models

enum ConfirmActionModels {
    enum Confirm {
        struct Request {
            let password: String
        }
        struct Response {
            let isValid: Bool
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

protocol ConfirmActionBusinessLogic {
    func confirmAction(request: ConfirmActionModels.Confirm.Request)
}

// MARK: - Routing Logic

protocol ConfirmActionRoutingLogic {
    func routeToPreviousScreen()
}

// MARK: - Presentation Logic

protocol ConfirmActionPresentationLogic {
    func presentConfirmAction(response: ConfirmActionModels.Confirm.Response)
}

// MARK: - Display Logic

protocol ConfirmActionDisplayLogic: AnyObject {
    func displayConfirmAction(viewModel: ConfirmActionModels.Confirm.ViewModel)
}

// MARK: - Interactor

final class ConfirmActionInteractor: ConfirmActionBusinessLogic {

    // MARK: - Properties

    var presenter: ConfirmActionPresentationLogic?
    private let user: User

    // MARK: - Initialization

    init(user: User) {
        self.user = user
    }

    // MARK: - Business Logic

    func confirmAction(request: ConfirmActionModels.Confirm.Request) {
        let isValid = (request.password == user.password)
        let errorMessage = isValid ? nil : "incorrect_password".localized
        let response = ConfirmActionModels.Confirm.Response(
            isValid: isValid,
            errorMessage: errorMessage
        )
        presenter?.presentConfirmAction(response: response)
    }
}
