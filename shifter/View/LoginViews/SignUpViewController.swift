import UIKit
import CoreData

// MARK: - Extension for checking the correct email
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
}

// MARK: - SignUpViewController
final class SignUpViewController: UIViewController, SignUpDisplayLogic, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    // MARK: - Clean Swift Components
    var interactor: SignUpBusinessLogic?
    var router: SignUpRoutingLogic?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign Up"
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.titleFontSize, weight: .bold)
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .regular)
        label.textColor = ColorsLayoutConstants.basicColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your email address"
        tf.font = UIFont.systemFont(ofSize: SizeLayoutConstants.textFieldFontSize)
        tf.borderStyle = .none
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .done
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
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .regular)
        label.textColor = ColorsLayoutConstants.basicColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your password"
        tf.font = UIFont.systemFont(ofSize: SizeLayoutConstants.textFieldFontSize)
        tf.isSecureTextEntry = true
        tf.borderStyle = .none
        tf.returnKeyType = .done
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let termsCheckBoxButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "square"), for: .normal)
        btn.tintColor = ColorsLayoutConstants.basicColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "I agree to the Terms of Services and Privacy Policy."
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize)
        label.textColor = ColorsLayoutConstants.linesColor
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        btn.backgroundColor = ColorsLayoutConstants.buttonColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: SizeLayoutConstants.buttonFontSize, weight: .bold)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let haveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "Have an Account?"
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize)
        label.textColor = ColorsLayoutConstants.specialTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign In", for: .normal)
        btn.setTitleColor(ColorsLayoutConstants.basicColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [haveAccountLabel, signInButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var isTermsChecked = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        
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
        
        view.backgroundColor = ColorsLayoutConstants.buttonTextColor
       
        view.addSubview(titleLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailUnderline)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordUnderline)
        view.addSubview(termsCheckBoxButton)
        view.addSubview(termsLabel)
        view.addSubview(continueButton)
        view.addSubview(bottomStack)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        setupConstraints()
        setupActions()
        
        navigationItem.hidesBackButton = true
        
        setupModule()
    }
    
    private func setupModule() {
        let interactor = SignUpInteractor()
        let presenter = SignUpPresenter()
        let router = SignUpRouter()
        
        self.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = self
        
        self.router = router
        router.viewController = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SignUpLayoutConstants.upperSize),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SignUpLayoutConstants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SignUpLayoutConstants.horizontalPadding),
            
            emailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: SignUpLayoutConstants.horizontalPadding),
            emailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: SignUpLayoutConstants.topAnchorSize),
            emailTextField.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            
            emailUnderline.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: SignUpLayoutConstants.topMiniSize),
            emailUnderline.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            emailUnderline.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            emailUnderline.heightAnchor.constraint(equalToConstant: 1),
            
            passwordLabel.topAnchor.constraint(equalTo: emailUnderline.bottomAnchor, constant: SignUpLayoutConstants.topAnchor2Size),
            passwordLabel.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: SignUpLayoutConstants.topAnchorSize),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            
            passwordUnderline.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: SignUpLayoutConstants.topMiniSize),
            passwordUnderline.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            passwordUnderline.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            passwordUnderline.heightAnchor.constraint(equalToConstant: 1),
        
            termsCheckBoxButton.topAnchor.constraint(equalTo: passwordUnderline.bottomAnchor, constant: SignUpLayoutConstants.topAnchor2Size),
            termsCheckBoxButton.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            termsCheckBoxButton.widthAnchor.constraint(equalToConstant: SignUpLayoutConstants.topAnchor2Size),
            termsCheckBoxButton.heightAnchor.constraint(equalToConstant: SignUpLayoutConstants.topAnchor2Size),
            
            termsLabel.centerYAnchor.constraint(equalTo: termsCheckBoxButton.centerYAnchor),
            termsLabel.leadingAnchor.constraint(equalTo: termsCheckBoxButton.trailingAnchor, constant: SignUpLayoutConstants.topMiniSize),
            termsLabel.trailingAnchor.constraint(equalTo: passwordUnderline.trailingAnchor),
       
            continueButton.topAnchor.constraint(equalTo: termsCheckBoxButton.bottomAnchor, constant: SignUpLayoutConstants.horizontalPadding),
            continueButton.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: SignUpLayoutConstants.topAnchor4Size),
            
            bottomStack.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: SignUpLayoutConstants.horizontalPadding),
            bottomStack.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    
    // MARK: - Actions
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        termsCheckBoxButton.addTarget(self, action: #selector(termsCheckBoxTapped), for: .touchUpInside)
    }
    
    // MARK: - Gesture Recognizer Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Toggle CheckBox
    @objc private func termsCheckBoxTapped() {
        isTermsChecked.toggle()
        let imageName = isTermsChecked ? "checkmark.square.fill" : "square"
        termsCheckBoxButton.setImage(UIImage(systemName: imageName), for: .normal)
        termsCheckBoxButton.tintColor = ColorsLayoutConstants.basicColor
    }
    
    // MARK: - Button Actions
    @objc private func signInTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func continueButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "pls_all_message".localized)
            return
        }
        
        guard email.isValidEmail else {
            showAlert(message: "pls_enter_valid_email".localized)
            return
        }
        
        guard isTermsChecked else {
            showAlert(message: "pls_accept_term".localized)
            return
        }
        
        let name = email.components(separatedBy: "@").first ?? ""
        
        let request = SignUp.Request(name: name, email: email, password: password)
        interactor?.signUp(request: request)
    }
    
    // MARK: - SignUpDisplayLogic
    func displaySignUp(viewModel: SignUp.ViewModel) {
        showAlert(
            message: viewModel.message,
            title: viewModel.message == "reg_success_message".localized ? "success_alert_title".localized : "Error"
        ) {
            if viewModel.message == "reg_success_message".localized {
                self.router?.routeToSignIn()
            }
        }
    }
    
    // MARK: - Alert Helper
    private func showAlert(message: String, title: String = "error_alert_title".localized, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
