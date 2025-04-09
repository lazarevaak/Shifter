import UIKit
import CoreData

// MARK: - Models

enum Settings {
    struct Request { }

    struct Response {
        let user: User
        let errorMessage: String?
    }

    struct ViewModel {
        let email: String?
        let password: String?
        let name: String?
        let language: String?
        let userId: UUID?
        let message: String
    }
}

// MARK: - Protocols

// MARK: - Business Logic
protocol SettingsBusinessLogic {
    func fetchSettings(request: Settings.Request)
    func updateLanguage(to language: String)
}

// MARK: - Routing Logic
protocol SettingsRoutingLogic: AnyObject {
    func routeToPreviousScreen()
    func routeToSignIn()
}

// MARK: - Presentation Logic
protocol SettingsPresentationLogic {
    func presentSettings(response: Settings.Response)
    func presentUpdateLanguageResult(success: Bool, errorMessage: String?)
}

// MARK: - Display Logic
protocol SettingsDisplayLogic: AnyObject {
    func displaySettings(viewModel: Settings.ViewModel)
    func displayUpdateLanguageResult(viewModel: Settings.ViewModel)
}

// MARK: - Протоколы подтверждения и обновления

protocol ConfirmActionDelegate: AnyObject {
    func didConfirmAction(withPassword input: String)
}

protocol EditPasswordDelegate: AnyObject {
    func didUpdatePassword(_ newPassword: String)
}

protocol EditLanguageDelegate: AnyObject {
    func didUpdateLanguage(_ newLanguage: String)
}

// MARK: - Interactor

final class SettingsInteractor: SettingsBusinessLogic {

    // MARK: - Properties

    var presenter: SettingsPresentationLogic?
    private let user: User

    // MARK: - Initialization

    init(user: User) {
        self.user = user
    }

    // MARK: - Business Logic

    func fetchSettings(request: Settings.Request) {
        let response = Settings.Response(user: user, errorMessage: nil)
        presenter?.presentSettings(response: response)
    }

    func updateLanguage(to language: String) {
        user.language = language
        do {
            try user.managedObjectContext?.save()
            presenter?.presentUpdateLanguageResult(success: true, errorMessage: nil)
        } catch {
            presenter?.presentUpdateLanguageResult(success: false, errorMessage: "error_save_settings".localized)
        }
    }
}
