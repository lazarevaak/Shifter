import UIKit

final class ConfirmActionViewController: UIViewController, ConfirmActionDisplayLogic {

    // MARK: - Properties
    weak var delegate: ConfirmActionDelegate?
    var interactor: ConfirmActionBusinessLogic?
    var router: ConfirmActionRoutingLogic?
    private let user: User

    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "confirm_action_title".localized
        label.font = UIFont.boldSystemFont(ofSize: ConfirmActionLayout.titleLabelSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "enter_current_password".localized
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("confirm_button_title".localized, for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = ConfirmActionLayout.buttoncornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("cancel_button_title".localized, for: .normal)
        button.tintColor = ColorsLayoutConstants.linesColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup VIP Cycle
    private func setup() {
        let interactor = ConfirmActionInteractor(user: user)
        let presenter = ConfirmActionPresenter()
        let router = ConfirmActionRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        setupLayout()
    }

    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(passwordTextField)
        view.addSubview(confirmButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: ConfirmActionLayout.topSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ConfirmActionLayout.sidePadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ConfirmActionLayout.sidePadding),

            passwordTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ConfirmActionLayout.topSpacing),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ConfirmActionLayout.sidePadding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ConfirmActionLayout.sidePadding),

            confirmButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: ConfirmActionLayout.topSpacing),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ConfirmActionLayout.sidePadding),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ConfirmActionLayout.sidePadding),
            confirmButton.heightAnchor.constraint(equalToConstant: ConfirmActionLayout.buttonHeight),

            cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: ConfirmActionLayout.betweenButtonsSpacing),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ConfirmActionLayout.sidePadding),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ConfirmActionLayout.sidePadding),
            cancelButton.heightAnchor.constraint(equalToConstant: ConfirmActionLayout.buttonHeight)
        ])
    }

    // MARK: - Actions
    @objc private func confirmTapped() {
        let enteredPassword = passwordTextField.text ?? ""
        let request = ConfirmActionModels.Confirm.Request(password: enteredPassword)
        interactor?.confirmAction(request: request)
    }

    @objc private func cancelTapped() {
        router?.routeToPreviousScreen()
    }

    // MARK: - Display Logic
    func displayConfirmAction(viewModel: ConfirmActionModels.Confirm.ViewModel) {
        if viewModel.success {
            delegate?.didConfirmAction(withPassword: passwordTextField.text ?? "")
            router?.routeToPreviousScreen()
        } else {
            let alert = UIAlertController(
                title: "error_alert_title".localized,
                message: viewModel.message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "ОК",
                style: .default)
            )
            present(alert, animated: true)
        }
    }
}
