import UIKit

final class ForgotPasswordViewController: UIViewController, ForgotPasswordDisplayLogic {
    
    // MARK: - Clean Swift Components
    var interactor: ForgotPasswordBusinessLogic?
    var router: ForgotPasswordRoutingLogic?
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Password Recovery"
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.titleFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email address"
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your email"
        tf.font = UIFont.systemFont(ofSize: SizeLayoutConstants.textFieldFontSize)
        tf.borderStyle = .none
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let textFieldUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sendCodeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send the code", for: .normal)
        btn.backgroundColor = ColorsLayoutConstants.buttonColor
        btn.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: SizeLayoutConstants.buttonFontSize, weight: .semibold)
        btn.layer.cornerRadius = ForgotPasswordConstants.buttonCornerRadius
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        navigationItem.title = ""
        navigationItem.hidesBackButton = true
        
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        setupActions()
        setupModule()
    }
    
    private func setupNavigationBar() {
        let backArrowButton = UIButton(type: .system)
        backArrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backArrowButton.tintColor = ColorsLayoutConstants.basicColor
        backArrowButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        let containerView = UIStackView(arrangedSubviews: [backArrowButton])
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.spacing = 8
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
    }
    
    private func setupSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(instructionLabel)
        view.addSubview(emailTextField)
        view.addSubview(textFieldUnderline)
        view.addSubview(sendCodeButton)
    }
    
    // MARK: - Module Configuration
    
    private func setupModule() {
        let interactor = ForgotPasswordInteractor()
        let presenter = ForgotPasswordPresenter()
        let router = ForgotPasswordRouter()
        
        self.interactor = interactor
        self.router = router
        
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }
    
    // MARK: - Layout Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: ForgotPasswordConstants.titleTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ForgotPasswordConstants.sideOffset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ForgotPasswordConstants.sideOffset),

            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ForgotPasswordConstants.instructionLabelTop),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ForgotPasswordConstants.sideOffset),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ForgotPasswordConstants.sideOffset),

            emailTextField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: ForgotPasswordConstants.emailTextFieldTop),
            emailTextField.leadingAnchor.constraint(equalTo: instructionLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: instructionLabel.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: ForgotPasswordConstants.textFieldHeight),

            textFieldUnderline.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            textFieldUnderline.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            textFieldUnderline.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            textFieldUnderline.heightAnchor.constraint(equalToConstant: ForgotPasswordConstants.underlineHeight),
  
            sendCodeButton.topAnchor.constraint(equalTo: textFieldUnderline.bottomAnchor, constant: ForgotPasswordConstants.sendCodeButtonTop),
            sendCodeButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            sendCodeButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            sendCodeButton.heightAnchor.constraint(equalToConstant: ForgotPasswordConstants.textFieldHeight)
        ])
    }
    
    // MARK: - Actions Setup
    
    private func setupActions() {
        sendCodeButton.addTarget(self, action: #selector(sendResetCodeButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sendResetCodeButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Пожалуйста, введите ваш email.")
            return
        }
        let request = ForgotPassword.Request(email: email)
        interactor?.sendResetCode(request: request)
    }
    
    // MARK: - ForgotPasswordDisplayLogic
    
    func displayForgotPassword(viewModel: ForgotPassword.ViewModel) {
        showAlert(message: viewModel.message, title: viewModel.success ? "success_alert_title".localized : "error_alert_title".localized) {
            if viewModel.success, let email = self.emailTextField.text {
                self.router?.routeToResetPassword(with: email)
            }
        }
    }
    
    // MARK: - Alert Helper
    private func showAlert(message: String, title: String = "Внимание", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in completion?() }
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
