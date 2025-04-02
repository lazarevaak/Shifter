import UIKit

protocol EditUsernameDelegate: AnyObject {
    func didUpdateUsername(_ newUsername: String)
}

final class EditUsernameViewController: UIViewController {
    
    weak var delegate: EditUsernameDelegate?
    
    private let userId: String
    private let currentUsername: String
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Change the user's name"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "New name"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    init(userId: String, currentUsername: String) {
        self.userId = userId
        self.currentUsername = currentUsername
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        usernameTextField.text = currentUsername
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(usernameTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            usernameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func saveTapped() {
        let newName = usernameTextField.text ?? ""
        guard !newName.isEmpty else {
            showAlert(message: "Please enter a new name.")
            return
        }
        
        // Обновляем имя пользователя в базе данных по userId
        UserDataManager.shared.updateUsername(for: userId, newName: newName) { [weak self] success in
            guard let self = self else { return }
            if success {
                print("Username updated for user id: \(self.userId) with new name: \(newName)")
                self.delegate?.didUpdateUsername(newName)
                self.dismiss(animated: true)
            } else {
                self.showAlert(message: "Failed to update username. Please try again.")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
