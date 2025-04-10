import UIKit

final class EditEmailViewController: UIViewController, EditEmailDisplayLogic {
    
    var interactor: EditEmailBusinessLogic?
    var router: EditEmailRoutingLogic?
    
    private let currentEmail: String
    private let userId: String
    weak var delegate: EditEmailDelegate?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "edit_email_title".localized
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.textTitleSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "new_email_placeholder".localized
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .emailAddress
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
    init(userId: String, currentEmail: String) {
        self.userId = userId
        self.currentEmail = currentEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        
        setup()
        setupLayout()
        emailTextField.text = currentEmail
    }
    
    private func setup() {
        let interactor = EditEmailInteractor(userId: userId, currentEmail: currentEmail)
        let presenter = EditEmailPresenter()
        let router = EditEmailRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SizeLayoutConstants.editConstaintSize),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: SizeLayoutConstants.editConstaintSize),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            
            saveButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: SizeLayoutConstants.editConstaintSize),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            saveButton.heightAnchor.constraint(equalToConstant: SizeLayoutConstants.editHeightAnchorSize)
        ])
    }
    
    // MARK: Actions
    @objc private func saveTapped() {
        let newEmail = emailTextField.text ?? ""
        let request = EditEmailModels.UpdateEmail.Request(newEmail: newEmail)
        interactor?.updateEmail(request: request)
    }
    
    // MARK: - EditEmailDisplayLogic
    func displayUpdateEmail(viewModel: EditEmailModels.UpdateEmail.ViewModel) {
        if viewModel.success {
            delegate?.didUpdateEmail(emailTextField.text ?? "")
            dismiss(animated: true)
        } else {
            let alert = UIAlertController(
                title: "error_alert_title".localized,
                message: viewModel.message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
    }
}
