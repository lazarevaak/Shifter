import UIKit

final class EditUsernameViewController: UIViewController, EditUsernameDisplayLogic {
    
    weak var delegate: EditUsernameDelegate?
    
    var interactor: EditUsernameBusinessLogic?
    var router: EditUsernameRoutingLogic?
    
    private let userId: String
    private let currentUsername: String
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "change_username_title".localized
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.textTitleSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "new_username_placeholder".localized
        tf.borderStyle = .roundedRect
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
    init(userId: String, currentUsername: String) {
        self.userId = userId
        self.currentUsername = currentUsername
        super.init(nibName: nil, bundle: nil)
        setupVIP()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVIP() {
        let interactor = EditUsernameInteractor(userId: userId, currentUsername: currentUsername)
        let presenter = EditUsernamePresenter()
        let router = EditUsernameRouter()
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
        usernameTextField.text = currentUsername
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(usernameTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: SizeLayoutConstants.editConstaintSize),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            
            usernameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: SizeLayoutConstants.editConstaintSize),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            
            saveButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: SizeLayoutConstants.editConstaintSize),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            saveButton.heightAnchor.constraint(equalToConstant: SizeLayoutConstants.editHeightAnchorSize)
        ])
    }
    
    @objc private func saveTapped() {
        guard let newName = usernameTextField.text, !newName.isEmpty else {
            showAlert(message: "empty_username_error".localized)
            return
        }
        let request = EditUsernameModels.UpdateUsername.Request(newName: newName)
        interactor?.updateUsername(request: request)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "error_alert_title".localized,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - EditUsernameDisplayLogic
    func displayUpdateUsername(viewModel: EditUsernameModels.UpdateUsername.ViewModel) {
        if viewModel.success {
            print("Username updated for user id: \(userId) with new name: \(usernameTextField.text ?? "")")
            delegate?.didUpdateUsername(usernameTextField.text ?? "")
            router?.routeToPreviousScreen()
        } else {
            showAlert(message: viewModel.message)
        }
    }
}
