import UIKit

class SignUpViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign Up"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.972, green: 0.373, blue: 0.416, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your email address"
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.972, green: 0.373, blue: 0.416, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your password"
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let termsSwitch: UIButton = {
        let button = UIButton(type: .system)
        let uncheckedImage = UIImage(systemName: "square")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(red: 0.972, green: 0.373, blue: 0.416, alpha: 1.0))
        let checkedImage = UIImage(systemName: "checkmark.square.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(red: 0.972, green: 0.373, blue: 0.416, alpha: 1.0))
        button.setImage(uncheckedImage, for: .normal)
        button.setImage(checkedImage, for: .selected)
        button.addTarget(self, action: #selector(termsToggled), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "I agree to the ", attributes: [.foregroundColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 10)])
        attributedText.append(NSAttributedString(string: "Terms of Services", attributes: [.foregroundColor: UIColor.red, .font: UIFont.boldSystemFont(ofSize: 10)]))
        attributedText.append(NSAttributedString(string: " and ", attributes: [.foregroundColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 10)]))
        attributedText.append(NSAttributedString(string: "Privacy Policy.", attributes: [.foregroundColor: UIColor.red, .font: UIFont.boldSystemFont(ofSize: 10)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.gray
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        setupLayout()
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField, passwordLabel, passwordTextField])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let termsStackView = UIStackView(arrangedSubviews: [termsSwitch, termsLabel])
        termsStackView.axis = .horizontal
        termsStackView.spacing = 8
        termsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        view.addSubview(termsStackView)
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            termsStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            termsStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            
            signUpButton.topAnchor.constraint(equalTo: termsStackView.bottomAnchor, constant: 20),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func termsToggled() {
        termsSwitch.isSelected.toggle()
        signUpButton.isEnabled = termsSwitch.isSelected
        signUpButton.backgroundColor = termsSwitch.isSelected ? UIColor(red: 0.972, green: 0.373, blue: 0.416, alpha: 1.0) : .gray
    }
    
    @objc private func signUpTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
