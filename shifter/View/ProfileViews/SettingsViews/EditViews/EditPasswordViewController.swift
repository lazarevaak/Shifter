import UIKit

final class EditPasswordViewController: UIViewController, EditPasswordDisplayLogic {
    
    weak var delegate: EditPasswordDelegate?
    
    var interactor: EditPasswordBusinessLogic?
    var router: EditPasswordRoutingLogic?
    
    private let userId: String
    private let currentPassword: String
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "change_password_title".localized
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.textTitleSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "new_password_placeholder".localized
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var confirmNewPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "confirm_new_password_placeholder".localized 
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("save_button_title".localized, for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(userId: String, currentPassword: String) {
        self.userId = userId
        self.currentPassword = currentPassword
        super.init(nibName: nil, bundle: nil)
        setupVIP()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
    private func setupVIP() {
        let interactor = EditPasswordInteractor(userId: userId, currentPassword: currentPassword)
        let presenter = EditPasswordPresenter()
        let router = EditPasswordRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(newPasswordTextField)
        view.addSubview(confirmNewPasswordTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: SizeLayoutConstants.editConstaintSize),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            
            newPasswordTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: SizeLayoutConstants.editConstaintSize),
            newPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            
            confirmNewPasswordTextField.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor, constant: 12),
            confirmNewPasswordTextField.leadingAnchor.constraint(equalTo: newPasswordTextField.leadingAnchor),
            confirmNewPasswordTextField.trailingAnchor.constraint(equalTo: newPasswordTextField.trailingAnchor),
            
            saveButton.topAnchor.constraint(equalTo: confirmNewPasswordTextField.bottomAnchor, constant: SizeLayoutConstants.editConstaintSize),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            saveButton.heightAnchor.constraint(equalToConstant: SizeLayoutConstants.editHeightAnchorSize)
        ])
    }
    
    @objc private func saveTapped() {
        let newPassword = newPasswordTextField.text ?? ""
        let confirmPassword = confirmNewPasswordTextField.text ?? ""
        
        guard !newPassword.isEmpty else {
            showAlert(message: "empty_password_error".localized)
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert(message: "passwords_mismatch_error".localized)
            return
        }
        
        let request = EditPasswordModels.UpdatePassword.Request(newPassword: newPassword)
        interactor?.updatePassword(request: request)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "error_alert_title".localized,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - EditPasswordDisplayLogic
    func displayUpdatePassword(viewModel: EditPasswordModels.UpdatePassword.ViewModel) {
        if viewModel.success {
            print("Password updated for user id: \(userId) with new password: \(newPasswordTextField.text ?? "")")
            delegate?.didUpdatePassword(newPasswordTextField.text ?? "")
            router?.routeToPreviousScreen()
        } else {
            showAlert(message: viewModel.message)
        }
    }
}
