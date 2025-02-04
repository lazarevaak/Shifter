import UIKit

class SettingsViewController: UIViewController {
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.red)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
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

    private func createTextField(placeholder: String, iconName: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = .gray
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        textField.leftView = icon
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }

    private lazy var usernameTextField = createTextField(placeholder: "Username", iconName: "person.fill")
    private lazy var emailTextField = createTextField(placeholder: "Email", iconName: "envelope.fill")
    private lazy var passwordTextField: UITextField = {
        let textField = createTextField(placeholder: "Password", iconName: "lock.fill")
        textField.isSecureTextEntry = true
        return textField
    }()

    private let languagePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let languageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Language"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let languages = ["English", "Русский"]

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        languageTextField.inputView = languagePicker
        languagePicker.dataSource = self
        languagePicker.delegate = self
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(usernameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(languageTextField)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            usernameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            
            languageTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            languageTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            languageTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
        ])
    }
    
    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        languageTextField.text = languages[row]
        languageTextField.resignFirstResponder()
    }
}
