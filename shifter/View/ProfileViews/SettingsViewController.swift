import UIKit
import CoreData

// MARK: - Протоколы подтверждения и обновления

protocol ConfirmActionDelegate: AnyObject {
    func didConfirmAction(withPassword input: String)
}

protocol EditPasswordDelegate: AnyObject {
    func didUpdatePassword(_ newPassword: String)
}

protocol EditEmailDelegate: AnyObject {
    func didUpdateEmail(_ newEmail: String)
}

protocol EditLanguageDelegate: AnyObject {
    func didUpdateLanguage(_ newLanguage: String)
}

final class SettingsViewController: UIViewController, SettingsDisplayLogic, UITextFieldDelegate, EditUsernameDelegate, EditPasswordDelegate, EditEmailDelegate, EditLanguageDelegate, ConfirmActionDelegate {
    
    // MARK: - Clean Swift Components
    var interactor: SettingsBusinessLogic?
    var router: SettingsRoutingLogic?
    
    // MARK: - Properties
    private var user: User
    private let languages = ["English", "Русский"]
    
    // Определяем тип запланированного действия после подтверждения
    private enum PendingAction {
        case editUsername
        case editPassword
        case editEmail
        case editLanguage
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
        label.text = "Settings"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// Создание текстового поля с иконкой слева и добавлением жеста для обработки нажатия
    private func createTextField(placeholder: String, iconName: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        if placeholder == "Password" {
            textField.isSecureTextEntry = true
        }
        // Оставляем userInteractionEnabled по умолчанию (true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textFieldTapped(_:)))
        textField.addGestureRecognizer(tapGesture)
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = ColorsLayoutConstants.specialTextColor
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
        let tf = createTextField(placeholder: "Username", iconName: "person.fill")
        tf.text = self.user.name
        return tf
    }()
    
    private lazy var emailTextField: UITextField = {
        let tf = createTextField(placeholder: "Email", iconName: "envelope.fill")
        tf.text = self.user.email
        return tf
    }()
    
    private lazy var passwordTextField: UITextField = {
        let tf = createTextField(placeholder: "Password", iconName: "lock.fill")
        tf.text = self.user.password
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let languageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Language"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let languagePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
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
        view.backgroundColor = ColorsLayoutConstants.buttonTextbackgroundColor
        
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
            usernameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            languageTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            languageTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            languageTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            logoutButton.topAnchor.constraint(equalTo: languageTextField.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Действия
    @objc private func backTapped() {
        router?.routeToPreviousScreen()
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Подтверждение",
                                      message: "Вы точно хотите выйти из аккаунта?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Выйти", style: .destructive) { _ in
            self.router?.routeToSignIn()
        }
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        present(alert, animated: true)
    }
    
    @objc private func textFieldTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedTextField = sender.view as? UITextField else { return }
        
        if tappedTextField == usernameTextField {
            pendingAction = .editUsername
            let confirmVC = ConfirmActionViewController()
            confirmVC.delegate = self
            if let sheet = confirmVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                confirmVC.modalPresentationStyle = .pageSheet
            }
            present(confirmVC, animated: true)
        } else if tappedTextField == passwordTextField {
            pendingAction = .editPassword
            let confirmVC = ConfirmActionViewController()
            confirmVC.delegate = self
            if let sheet = confirmVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                confirmVC.modalPresentationStyle = .pageSheet
            }
            present(confirmVC, animated: true)
        } else if tappedTextField == emailTextField {
            pendingAction = .editEmail
            let confirmVC = ConfirmActionViewController()
            confirmVC.delegate = self
            if let sheet = confirmVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                confirmVC.modalPresentationStyle = .pageSheet
            }
            present(confirmVC, animated: true)
        } else if tappedTextField == languageTextField {
            pendingAction = .editLanguage
            let confirmVC = ConfirmActionViewController()
            confirmVC.delegate = self
            if let sheet = confirmVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                confirmVC.modalPresentationStyle = .pageSheet
            }
            present(confirmVC, animated: true)
        } else {
            tappedTextField.becomeFirstResponder()
        }
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
        let title = viewModel.message.contains("Error") ? "Error" : "Success"
        showAlert(message: message, title: title)
    }
    
    // MARK: - Alert Helper
    private func showAlert(message: String, title: String = "Alert", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in completion?() }
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
    }
    
    func didUpdateLanguage(_ newLanguage: String) {
        user.language = newLanguage
        languageTextField.text = newLanguage
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
            showAlert(message: "Неправильное подтверждение", title: "Ошибка")
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
                editVC.modalPresentationStyle = .pageSheet
            }
            self.present(editVC, animated: true)
        case .editPassword:
            let editPassVC = EditPasswordViewController(currentPassword: self.user.password ?? "")
            editPassVC.delegate = self
            if let sheet = editPassVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                editPassVC.modalPresentationStyle = .pageSheet
            }
            self.present(editPassVC, animated: true)
        case .editEmail:
            let editEmailVC = EditEmailViewController(currentEmail: self.user.email ?? "")
            editEmailVC.delegate = self
            if let sheet = editEmailVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                editEmailVC.modalPresentationStyle = .pageSheet
            }
            self.present(editEmailVC, animated: true)
        case .editLanguage:
            let editLanguageVC = EditLanguageViewController(currentLanguage: self.user.language ?? "", languages: self.languages)
            editLanguageVC.delegate = self
            if let sheet = editLanguageVC.sheetPresentationController, #available(iOS 15.0, *) {
                sheet.detents = [UISheetPresentationController.Detent.medium()]
            } else {
                editLanguageVC.modalPresentationStyle = .pageSheet
            }
            self.present(editLanguageVC, animated: true)
        }
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLanguage = languages[row]
        languageTextField.text = selectedLanguage
        languageTextField.resignFirstResponder()
        interactor?.updateLanguage(to: selectedLanguage)
    }
}
