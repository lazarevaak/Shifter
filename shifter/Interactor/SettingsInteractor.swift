import UIKit
import CoreData

final class SettingsInteractor: SettingsBusinessLogic {
    var presenter: SettingsPresentationLogic?
    private let user: User

    init(user: User) {
        self.user = user
    }
    
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
            presenter?.presentUpdateLanguageResult(success: false, errorMessage: "Ошибка при сохранении настроек.")
        }
    }
}

