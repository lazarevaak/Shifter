import UIKit
import CoreData

final class SettingsViewController: UIViewController, SettingsDisplayLogic, UITextFieldDelegate, EditUsernameDelegate, EditPasswordDelegate, EditEmailDelegate, EditLanguageDelegate, ConfirmActionDelegate {
 
    // MARK: - Clean Swift Components
    var interactor: SettingsBusinessLogic?
    var router: SettingsRoutingLogic?
        
    private var user: User
    // Используем словарь: ключ – код, значение – отображаемое имя языка
    private let languages: [String: String] = [
        "en": "English",
        "ru": "Русский"
    ]
        
    private enum PendingAction {
        case editUsername, editPassword, editEmail, editLanguage
    }
    private var pendingAction: PendingAction?
    
    // MARK: - UI Elements
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.left")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        // Локализованный заголовок экрана настроек
        label.text = "settings_title".localized
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func createTextField(placeholder: String, iconName: String) -> UITextField {
        let textField = UITextField()
        // При создании placeholder можно передать уже локализованную строку
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize)
        if placeholder == "Password" {
            textField.isSecureTextEntry = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped(_:)))
        textField.addGestureRecognizer(tapGesture)
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = ColorsLayoutConstants.basicColor
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        container.addSubview(icon)
        textField.leftView = container
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }
    
    private lazy var usernameTextField: UITextField = {
        let tf = createTextField(placeholder: "username_placeholder".localized, iconName: "person.fill")
        tf.text = self.user.name
        return tf
    }()
    
    private lazy var emailTextField: UITextField = {
        let tf = createTextField(placeholder: "email_placeholder".localized, iconName: "envelope.fill")
        tf.text = self.user.email
        return tf
    }()
    
    private lazy var passwordTextField: UITextField = {
        let tf = createTextField(placeholder: "password_placeholder".localized, iconName: "lock.fill")
        tf.text = self.user.password
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let languageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "language_placeholder".localized
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let languagePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("logout_button_title".localized, for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: SizeLayoutConstants.buttonFontSize, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Инициализатор
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        
        languageTextField.inputView = languagePicker
        languagePicker.dataSource = self
        languagePicker.delegate = self
        
        let languageTapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped(_:)))
        languageTextField.addGestureRecognizer(languageTapGesture)
        languageTextField.delegate = self
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        setupLayout()
        setupModule()
        interactor?.fetchSettings(request: Settings.Request())
        
        // Подписка для мгновенного обновления интерфейса при смене языка
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizedTexts), name: Notification.Name("LanguageDidChange"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Module Configuration
    private func setupModule() {
        let interactor = SettingsInteractor(user: self.user)
        let presenter = SettingsPresenter()
        let router = SettingsRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(titleUnderline)
        view.addSubview(usernameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(languageTextField)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleUnderline.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            titleUnderline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleUnderline.heightAnchor.constraint(equalToConstant: 0.5),
            
            usernameTextField.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor, constant: 32),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            languageTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            languageTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            languageTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            languageTextField.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.topAnchor.constraint(equalTo: languageTextField.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .reveal
        transition.subtype = .fromLeft
        view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "logout_confirm_title".localized,
                                      message: "logout_confirm_message".localized,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "logout_cancel".localized, style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "logout_action".localized, style: .destructive) { _ in
            self.router?.routeToSignIn()
        }
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        present(alert, animated: true)
    }
    
    @objc private func textFieldTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedTextField = sender.view as? UITextField else { return }
        
        let confirmVC = ConfirmActionViewController(user: self.user)
        confirmVC.delegate = self
        if let sheet = confirmVC.sheetPresentationController, #available(iOS 15.0, *) {
            sheet.detents = [UISheetPresentationController.Detent.medium()]
        } else {
            confirmVC.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        }
        
        if tappedTextField == usernameTextField {
            pendingAction = .editUsername
        } else if tappedTextField == passwordTextField {
            pendingAction = .editPassword
        } else if tappedTextField == emailTextField {
            pendingAction = .editEmail
        } else if tappedTextField == languageTextField {
            pendingAction = .editLanguage
        } else {
            tappedTextField.becomeFirstResponder()
            return
        }
        
        present(confirmVC, animated: true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) { }
    
    // MARK: - SettingsDisplayLogic
    func displaySettings(viewModel: Settings.ViewModel) {
        emailTextField.text = viewModel.email
        usernameTextField.text = viewModel.name
        passwordTextField.text = viewModel.password
        languageTextField.text = viewModel.language
    }
    
    func displayUpdateLanguageResult(viewModel: Settings.ViewModel) {
        let message = viewModel.message
        let title = viewModel.message.contains("error_alert_title".localized) ? "error_alert_title".localized : "success_alert_title".localized
        showAlert(message: message, title: title)
    }
    
    // MARK: - Alert Helper
    private func showAlert(message: String, title: String = "alert_default_title".localized, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok_button_title".localized, style: .default) { _ in completion?() }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    // MARK: - Delegates
    func didUpdateUsername(_ newUsername: String) {
        user.name = newUsername
        usernameTextField.text = newUsername
    }
    
    func didUpdatePassword(_ newPassword: String) {
        user.password = newPassword
        passwordTextField.text = newPassword
    }
    
    func didUpdateEmail(_ newEmail: String) {
        user.email = newEmail
        emailTextField.text = newEmail
        UserDefaults.standard.set(newEmail, forKey: "LoggedInUserEmail")
    }
    
    func didUpdateLanguage(_ newLanguage: String) {
        user.language = newLanguage
        languageTextField.text = newLanguage
        UserDefaults.standard.set(newLanguage, forKey: "AppLanguage")
        
        let idString = self.user.objectID.uriRepresentation().absoluteString
        UserDataManager.shared.updateLanguage(for: idString, newLanguage: newLanguage) { success in
            if success {
                print("Language updated successfully to \(newLanguage)")
            } else {
                print("Failed to update language")
            }
        }
        
        // Обновляем экран сразу же при смене языка
        updateLocalizedTexts()
    }
    
    func didConfirmAction(withPassword input: String) {
        if input == self.user.password {
            if let action = pendingAction {
                if let presentedVC = self.presentedViewController {
                    presentedVC.dismiss(animated: true) {
                        self.presentEditController(for: action)
                    }
                } else {
                    self.presentEditController(for: action)
                }
                pendingAction = nil
            }
        } else {
            showAlert(message: "confirm_password_error".localized, title: "error_alert_title".localized)
        }
    }
    
    private func presentEditController(for action: PendingAction) {
        switch action {
        case .editUsername:
            let idString = self.user.objectID.uriRepresentation().absoluteString
            let editVC = EditUsernameViewController(userId: idString, currentUsername: self.user.name ?? "")
            editVC.delegate = self
            if let sheet = editVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                editVC.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            }
            self.present(editVC, animated: true)
            
        case .editPassword:
            let idString = self.user.objectID.uriRepresentation().absoluteString
            let editPassVC = EditPasswordViewController(userId: idString, currentPassword: self.user.password ?? "")
            editPassVC.delegate = self
            if let sheet = editPassVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                editPassVC.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            }
            self.present(editPassVC, animated: true)
            
        case .editEmail:
            let idString = self.user.objectID.uriRepresentation().absoluteString
            let editEmailVC = EditEmailViewController(userId: idString, currentEmail: self.user.email ?? "")
            editEmailVC.delegate = self
            if let sheet = editEmailVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                editEmailVC.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            }
            self.present(editEmailVC, animated: true)
            
        case .editLanguage:
            let editLanguageVC = EditLanguageViewController(currentLanguage: self.user.language ?? "", languages: self.languages)
            editLanguageVC.delegate = self
            if let sheet = editLanguageVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                editLanguageVC.modalPresentationStyle = UIModalPresentationStyle.pageSheet
            }
            self.present(editLanguageVC, animated: true)
        }
    }
    
    @objc private func updateLocalizedTexts() {
        titleLabel.text = "settings_title".localized
        usernameTextField.placeholder = "username_placeholder".localized
        emailTextField.placeholder = "email_placeholder".localized
        passwordTextField.placeholder = "password_placeholder".localized
        languageTextField.placeholder = "language_placeholder".localized
        logoutButton.setTitle("logout_button_title".localized, for: .normal)
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let codes = Array(languages.keys).sorted()
        let code = codes[row]
        return languages[code] ?? code
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let codes = Array(languages.keys).sorted()
        let selectedLanguage = codes[row]
        languageTextField.text = languages[selectedLanguage]
        languageTextField.resignFirstResponder()
        interactor?.updateLanguage(to: selectedLanguage)
    }
}
