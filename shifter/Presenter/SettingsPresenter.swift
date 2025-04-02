import UIKit

enum Settings {
    struct Request {
    }
    
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

protocol SettingsBusinessLogic {
    func fetchSettings(request: Settings.Request)
    func updateLanguage(to language: String)
}

protocol SettingsPresentationLogic {
    func presentSettings(response: Settings.Response)
    func presentUpdateLanguageResult(success: Bool, errorMessage: String?)
}

protocol SettingsDisplayLogic: AnyObject {
    func displaySettings(viewModel: Settings.ViewModel)
    func displayUpdateLanguageResult(viewModel: Settings.ViewModel)
}

final class SettingsPresenter: SettingsPresentationLogic {
    weak var viewController: SettingsDisplayLogic?
    
    func presentSettings(response: Settings.Response) {
        let viewModel = Settings.ViewModel(
            email: response.user.email,
            password: response.user.password,
            name: response.user.name,
            language: response.user.language,
            userId: response.user.userId,
            message: "Настройки загружены."
        )
        viewController?.displaySettings(viewModel: viewModel)
    }
    
    func presentUpdateLanguageResult(success: Bool, errorMessage: String?) {
        let message = success ? "Язык успешно сохранён." : (errorMessage ?? "Ошибка обновления языка.")
        let viewModel = Settings.ViewModel(
            email: nil,
            password: nil,
            name: nil,
            language: nil,
            userId: nil,
            message: message
        )
        viewController?.displayUpdateLanguageResult(viewModel: viewModel)
    }
}
