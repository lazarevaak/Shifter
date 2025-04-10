import UIKit

final class SignInViewController: UIViewController,
                                  SignInDisplayLogic,
                                  UIGestureRecognizerDelegate,
                                  UITextFieldDelegate
{
    // MARK: - Clean Swift Components
    var interactor: SignInBusinessLogic?
    var router: SignInRoutingLogic?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign In"
        label.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleFontSize, weight: .bold)
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hi there! Nice to see you again."
        label.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleFieldSize, weight: .regular)
        label.textColor = ColorsLayoutConstants.specialTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleLabelSize, weight: .regular)
        label.textColor = ColorsLayoutConstants.basicColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "example@email.com"
        tf.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleFieldSize)
        tf.borderStyle = .none
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let emailUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleLabelSize, weight: .regular)
        label.textColor = ColorsLayoutConstants.basicColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleFieldSize)
        tf.isSecureTextEntry = true
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var passwordVisibilityButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.setImage(UIImage(systemName: "eye"), for: .selected)
        btn.tintColor = ColorsLayoutConstants.specialTextColor
        btn.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        btn.frame = CGRect(x: SignInLayoutConstants.passwordIconX,
                           y: SignInLayoutConstants.passwordIconY,
                           width: SignInLayoutConstants.passwordIconSize,
                           height: SignInLayoutConstants.passwordIconSize)
        return btn
    }()
    
    private lazy var passwordContainerView: UIView = {
        let container = UIView(frame: CGRect(x: 0, y: 0,
                                             width: SignInLayoutConstants.passwordIconContainerWidth,
                                             height: SignInLayoutConstants.passwordIconContainerHeight))
        container.addSubview(passwordVisibilityButton)
        return container
    }()
    
    private let passwordUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let signInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign in", for: .normal)
        btn.backgroundColor = ColorsLayoutConstants.buttonColor
        btn.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleFieldSize, weight: .semibold)
        btn.layer.cornerRadius = SignInLayoutConstants.cornerRadius
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "or use one of your social profiles"
        label.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleLabelSize)
        label.textColor = ColorsLayoutConstants.linesColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.setTitleColor(ColorsLayoutConstants.specialTextColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleLabelSize)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(ColorsLayoutConstants.basicColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: SignInLayoutConstants.titleLabelSize, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var bottomButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [forgotPasswordButton, signUpButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = SignInLayoutConstants.bottomStackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        
        setupGestures()
        setupUI()
        setupConstraints()
        setupActions()
        setupModule()
    }
    
    // MARK: - Setup
    private func setupModule() {
        let interactor = SignInInteractor()
        let presenter = SignInPresenter()
        let router = SignInRouter()
        
        self.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = self
        
        self.router = router
        router.viewController = self
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDownGesture.direction = .down
        swipeDownGesture.delegate = self
        view.addGestureRecognizer(swipeDownGesture)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeUpGesture.direction = .up
        swipeUpGesture.delegate = self
        view.addGestureRecognizer(swipeUpGesture)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailUnderline)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordUnderline)
        view.addSubview(signInButton)
        view.addSubview(orLabel)
        view.addSubview(bottomButtonsStack)
        
        passwordTextField.rightView = passwordContainerView
        passwordTextField.rightViewMode = .always
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: SignInLayoutConstants.topTitlePadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: SignInLayoutConstants.sidePadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -SignInLayoutConstants.sidePadding),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                               constant: SignInLayoutConstants.subtitleTopSpacing),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor,
                                            constant: SignInLayoutConstants.fieldLabelTopSpacing),
            emailLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor,
                                                constant: SignInLayoutConstants.textFieldTopSpacing),
            emailTextField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            
            emailUnderline.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,
                                                constant: SignInLayoutConstants.textFieldTopSpacing),
            emailUnderline.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            emailUnderline.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            emailUnderline.heightAnchor.constraint(equalToConstant: SignInLayoutConstants.underlineHeight),
            
            passwordLabel.topAnchor.constraint(equalTo: emailUnderline.bottomAnchor,
                                               constant: SignInLayoutConstants.fieldToNextFieldSpacing),
            passwordLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor,
                                                   constant: SignInLayoutConstants.textFieldTopSpacing),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            
            passwordUnderline.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,
                                                   constant: SignInLayoutConstants.textFieldTopSpacing),
            passwordUnderline.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            passwordUnderline.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            passwordUnderline.heightAnchor.constraint(equalToConstant: SignInLayoutConstants.underlineHeight),
            
            signInButton.topAnchor.constraint(equalTo: passwordUnderline.bottomAnchor,
                                              constant: SignInLayoutConstants.buttonTopSpacing),
            signInButton.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: SignInLayoutConstants.buttonHeight),
            
            orLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor,
                                         constant: SignInLayoutConstants.orLabelTopSpacing),
            orLabel.leadingAnchor.constraint(equalTo: signInButton.leadingAnchor),
            orLabel.trailingAnchor.constraint(equalTo: signInButton.trailingAnchor),
            
            bottomButtonsStack.topAnchor.constraint(equalTo: orLabel.bottomAnchor,
                                                    constant: SignInLayoutConstants.bottomStackTopSpacing),
            bottomButtonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Gesture Recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Toggle Password Visibility
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        passwordVisibilityButton.isSelected.toggle()
    }
    
    // MARK: - Button Actions
    @objc private func signInButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "pls_all_message".localized)
            return
        }
        
        let request = SignIn.Request(email: email, password: password)
        interactor?.signIn(request: request)
    }
    
    @objc private func forgotPasswordTapped() {
        router?.routeToForgotPassword()
    }
    
    @objc private func signUpButtonTapped() {
        router?.routeToSignUp()
    }
    
    // MARK: - SignInDisplayLogic
    func displaySignIn(viewModel: SignIn.ViewModel) {
        if viewModel.message == "welcome_message".localized, let user = viewModel.user {
            router?.routeToProfile(with: user)
        } else {
            showAlert(message: viewModel.message)
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Alert
    private func showAlert(message: String, title: String = "Error") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
