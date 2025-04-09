import Foundation

final class LocalizationManager {
    // MARK: - Singleton
    static let shared = LocalizationManager()
    
    // MARK: - Properties
    private var bundle: Bundle?
    private(set) var selectedLanguage: String
    
    // MARK: - Initialization
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            self.selectedLanguage = savedLanguage
        } else {
            self.selectedLanguage = "en"
        }
        updateBundle()
    }
    
    // MARK: - Public Methods
    func updateLanguage(to language: String) {
        selectedLanguage = language
        UserDefaults.standard.set(language, forKey: "AppLanguage")
        updateBundle()
        NotificationCenter.default.post(name: Notification.Name("LanguageDidChange"), object: nil)
    }
    
    func localizedString(for key: String, comment: String = "") -> String {
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
    
    // MARK: - Private Methods
    private func updateBundle() {
        if let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
           let langBundle = Bundle(path: path) {
            bundle = langBundle
        } else {
            bundle = Bundle.main
        }
    }
}

// MARK: - String Extension
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}
