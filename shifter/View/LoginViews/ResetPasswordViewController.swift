import UIKit
import CoreData

// MARK: - ViewController
final class ResetPasswordViewController: UIViewController, ResetPasswordDisplayLogic {

    // MARK: - Properties
    var interactor: ResetPasswordBusinessLogic?
    var router: ResetPasswordRoutingLogic?

    // MARK: - Feature Data
    private let email: String

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Password Reset"
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.font = UIFont.systemFont(ofSize: ResetPasswordConstants.titleFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let codeInstructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter the code from the email"
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: ResetPasswordConstants.instructionFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let codeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your code"
        tf.font = UIFont.systemFont(ofSize: ResetPasswordConstants.textFieldFontSize)
        tf.borderStyle = .none
        tf.keyboardType = .numberPad
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let codeUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.specialTextColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let passwordInstructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter a new password"
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: ResetPasswordConstants.instructionFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "New password"
        tf.font = UIFont.systemFont(ofSize: ResetPasswordConstants.textFieldFontSize)
        tf.borderStyle = .none
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let passwordUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.specialTextColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let resetButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Reset password", for: .normal)
        btn.backgroundColor = ColorsLayoutConstants.buttonColor
        btn.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: ResetPasswordConstants.buttonFontSize, weight: .semibold)
        btn.layer.cornerRadius = ResetPasswordConstants.cornerRadius
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Initialization
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor

        navigationItem.title = ""
        navigationItem.hidesBackButton = true

        let backArrowButton = UIButton(type: .system)
        backArrowButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backArrowButton.tintColor = ColorsLayoutConstants.basicColor
        backArrowButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        let containerView = UIStackView(arrangedSubviews: [backArrowButton])
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.spacing = 8
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)

        view.addSubview(titleLabel)
        view.addSubview(codeInstructionLabel)
        view.addSubview(codeTextField)
        view.addSubview(codeUnderline)
        view.addSubview(passwordInstructionLabel)
        view.addSubview(newPasswordTextField)
        view.addSubview(passwordUnderline)
        view.addSubview(resetButton)

        setupConstraints()
        setupActions()
        setupModule()
    }

    // MARK: - Module Setup
    private func setupModule() {
        let interactor = ResetPasswordInteractor()
        let presenter = ResetPasswordPresenter()
        let router = ResetPasswordRouter()

        self.interactor = interactor
        self.router = router

        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }

    // MARK: - Layout
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: ResetPasswordConstants.titleTopPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: ResetPasswordConstants.leadingTrailingInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -ResetPasswordConstants.leadingTrailingInset),

            codeInstructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                                      constant: ResetPasswordConstants.codeInstructionTopPadding),
            codeInstructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                          constant: ResetPasswordConstants.leadingTrailingInset),
            codeInstructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                           constant: -ResetPasswordConstants.leadingTrailingInset),

            codeTextField.topAnchor.constraint(equalTo: codeInstructionLabel.bottomAnchor,
                                               constant: ResetPasswordConstants.codeTextFieldTopPadding),
            codeTextField.leadingAnchor.constraint(equalTo: codeInstructionLabel.leadingAnchor),
            codeTextField.trailingAnchor.constraint(equalTo: codeInstructionLabel.trailingAnchor),
            codeTextField.heightAnchor.constraint(equalToConstant: ResetPasswordConstants.codeTextFieldHeight),

            codeUnderline.topAnchor.constraint(equalTo: codeTextField.bottomAnchor),
            codeUnderline.leadingAnchor.constraint(equalTo: codeTextField.leadingAnchor),
            codeUnderline.trailingAnchor.constraint(equalTo: codeTextField.trailingAnchor),
            codeUnderline.heightAnchor.constraint(equalToConstant: 1),

            passwordInstructionLabel.topAnchor.constraint(equalTo: codeUnderline.bottomAnchor,
                                                          constant: ResetPasswordConstants.passwordInstructionTopPadding),
            passwordInstructionLabel.leadingAnchor.constraint(equalTo: codeTextField.leadingAnchor),
            passwordInstructionLabel.trailingAnchor.constraint(equalTo: codeTextField.trailingAnchor),

            newPasswordTextField.topAnchor.constraint(equalTo: passwordInstructionLabel.bottomAnchor,
                                                      constant: ResetPasswordConstants.passwordTextFieldTopPadding),
            newPasswordTextField.leadingAnchor.constraint(equalTo: passwordInstructionLabel.leadingAnchor),
            newPasswordTextField.trailingAnchor.constraint(equalTo: passwordInstructionLabel.trailingAnchor),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: ResetPasswordConstants.passwordTextFieldHeight),

            passwordUnderline.topAnchor.constraint(equalTo: newPasswordTextField.bottomAnchor),
            passwordUnderline.leadingAnchor.constraint(equalTo: newPasswordTextField.leadingAnchor),
            passwordUnderline.trailingAnchor.constraint(equalTo: newPasswordTextField.trailingAnchor),
            passwordUnderline.heightAnchor.constraint(equalToConstant: 1),

            resetButton.topAnchor.constraint(equalTo: passwordUnderline.bottomAnchor,
                                             constant: ResetPasswordConstants.resetButtonTopPadding),
            resetButton.leadingAnchor.constraint(equalTo: newPasswordTextField.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: newPasswordTextField.trailingAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: ResetPasswordConstants.resetButtonHeight)
        ])
    }

    // MARK: - Actions Setup
    private func setupActions() {
        resetButton.addTarget(self, action: #selector(resetPasswordButtonTapped), for: .touchUpInside)
    }

    // MARK: - Button Actions
    @objc private func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func resetPasswordButtonTapped() {
        guard let code = codeTextField.text, !code.isEmpty,
              let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showAlert(message: "pls_all_message".localized)
            return
        }

        let request = ResetPassword.Request(code: code, newPassword: newPassword, email: email)
        interactor?.resetPassword(request: request)
    }

    // MARK: - Display Logic
    func displayResetPassword(viewModel: ResetPassword.ViewModel) {
        showAlert(message: viewModel.message, title: viewModel.success ? "success_alert_title".localized : "error_alert_title".localized) {
            if viewModel.success {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    // MARK: - Alert Helper
    private func showAlert(message: String, title: String = "Attention", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in completion?() }
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
