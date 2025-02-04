import UIKit

class SignInViewController: UIViewController {
    
    let signInLabel = UILabel()
    let hiLabel = UILabel()
    let emailLabel = UILabel()
    let emailTextField = UITextField()
    let passwordLabel = UILabel()
    let passwordTextField = UITextField()
    let showPasswordButton = UIButton(type: .system)
    let signInButton = UIButton()
    let forgotPasswordButton = UIButton()
    let signUpButton = UIButton()
    let socialProfilesLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        
    }
    
    @objc func signUpButtonTapped() {
        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func setupUI() {
        signInLabel.text = "Sign In"
        signInLabel.font = UIFont.boldSystemFont(ofSize: 30)
        signInLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInLabel)
        
        hiLabel.text = "Hi there! Nice to see you again."
        hiLabel.font = UIFont.systemFont(ofSize: 16)
        hiLabel.textColor = .gray
        hiLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hiLabel)
        
        emailLabel.text = "Email"
        emailLabel.font = UIFont.boldSystemFont(ofSize: 14)
        emailLabel.textColor = UIColor(hex: "#F85F6A")
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailLabel)
        
        emailTextField.placeholder = "example@email.com"
        emailTextField.borderStyle = .roundedRect
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailTextField)
        
        passwordLabel.text = "Password"
        passwordLabel.font = UIFont.boldSystemFont(ofSize: 14)
        passwordLabel.textColor = UIColor(hex: "#F85F6A")
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordLabel)
        
        passwordTextField.placeholder = "••••••••"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordTextField)

        showPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        showPasswordButton.tintColor = .lightGray
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        showPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showPasswordButton)

        signInButton.setTitle("Sign In", for: .normal)
        signInButton.backgroundColor = UIColor(hex: "#AAAAAA")
        signInButton.layer.cornerRadius = 8
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signInButton)

        socialProfilesLabel.text = "or use one of your social profiles"
        socialProfilesLabel.font = UIFont.systemFont(ofSize: 14)
        socialProfilesLabel.textColor = .gray
        socialProfilesLabel.textAlignment = .center
        socialProfilesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(socialProfilesLabel)
  
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.setTitleColor(.gray, for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(forgotPasswordButton)

        signUpButton.setTitle("Sign Up", for: .normal)
                signUpButton.setTitleColor(UIColor(hex: "#F85F6A"), for: .normal)
                signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                signUpButton.translatesAutoresizingMaskIntoConstraints = false
                signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
                view.addSubview(signUpButton)
     
        NSLayoutConstraint.activate([
            signInLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            signInLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            hiLabel.topAnchor.constraint(equalTo: signInLabel.bottomAnchor, constant: 25),
            hiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            emailLabel.topAnchor.constraint(equalTo: hiLabel.bottomAnchor, constant: 50),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 5),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            emailTextField.heightAnchor.constraint(equalToConstant: 45),
            
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 25),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 5),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 45),
            
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordTextField.centerYAnchor),
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: -10),
            showPasswordButton.widthAnchor.constraint(equalToConstant: 30),
            showPasswordButton.heightAnchor.constraint(equalToConstant: 30),
            
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 50),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            socialProfilesLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 30),
            socialProfilesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: socialProfilesLabel.bottomAnchor, constant: 25),
            forgotPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            
            signUpButton.topAnchor.constraint(equalTo: socialProfilesLabel.bottomAnchor, constant: 25),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let eyeIcon = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        showPasswordButton.setImage(UIImage(systemName: eyeIcon), for: .normal)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
