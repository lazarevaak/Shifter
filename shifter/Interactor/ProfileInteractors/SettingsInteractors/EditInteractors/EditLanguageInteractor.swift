import Foundation

// MARK: - Models

enum EditLanguageModels {
    enum UpdateLanguage {
        struct Request {
            let newLanguage: String
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

protocol EditLanguageBusinessLogic {
    func updateLanguage(request: EditLanguageModels.UpdateLanguage.Request)
}

// MARK: - Routing Logic

protocol EditLanguageRoutingLogic {
    func routeToPreviousScreen()
}

// MARK: - Presentation Logic

protocol EditLanguagePresentationLogic {
    func presentUpdateLanguage(response: EditLanguageModels.UpdateLanguage.Response)
}

// MARK: - Display Logic

protocol EditLanguageDisplayLogic: AnyObject {
    func displayUpdateLanguage(viewModel: EditLanguageModels.UpdateLanguage.ViewModel)
}

// MARK: - Interactor

final class EditLanguageInteractor: EditLanguageBusinessLogic {

    // MARK: - Properties

    var presenter: EditLanguagePresentationLogic?

    // MARK: - Business Logic

    func updateLanguage(request: EditLanguageModels.UpdateLanguage.Request) {
        if request.newLanguage.isEmpty {
            let response = EditLanguageModels.UpdateLanguage.Response(
                success: false,
                message: "error_select_language".localized
            )
            presenter?.presentUpdateLanguage(response: response)
        } else {
            let response = EditLanguageModels.UpdateLanguage.Response(
                success: true,
                message: "language_update_success".localized
            )
            presenter?.presentUpdateLanguage(response: response)
        }
    }
}
