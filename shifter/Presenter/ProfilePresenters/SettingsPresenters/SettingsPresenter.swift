import UIKit

// MARK: - Presenter
final class SettingsPresenter: SettingsPresentationLogic {

    // MARK: - Properties
    weak var viewController: SettingsDisplayLogic?

    // MARK: - Presentation Logic
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
