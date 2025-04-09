import UIKit
import CoreData

final class CreateSetViewController: UIViewController, CreateSetDisplayLogic {
    
    // MARK: - Clean Swift Components
    var interactor: CreateSetBusinessLogic?
    var router: CreateSetRoutingLogic?
    
    // MARK: - UI Elements
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "checkmark")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "сreatingset_label".localized
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.titleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameOfSetLabel: UILabel = {
        let label = UILabel()
        label.text = "nameset_label".localized
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: CreateSetConstants.labelFontSizeMedium, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameOfSetTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "name_label".localized,
            attributes: [.foregroundColor: ColorsLayoutConstants.linesColor]
        )
        tf.font = UIFont.systemFont(ofSize: CreateSetConstants.textFieldFontSize)
        return tf
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "descriptionset_label".localized
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: CreateSetConstants.labelFontSizeMedium, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "description_label".localized,
            attributes: [.foregroundColor: ColorsLayoutConstants.linesColor]
        )
        tf.font = UIFont.systemFont(ofSize: CreateSetConstants.textFieldFontSize)
        return tf
    }()
    
    private let textOfSetLabel: UILabel = {
        let label = UILabel()
        label.text = "textset_label".localized
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: CreateSetConstants.labelFontSizeMedium, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textOfSetTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: CreateSetConstants.textViewFontSize)
        tv.layer.borderWidth = CreateSetConstants.textViewBorderWidth
        tv.layer.borderColor = ColorsLayoutConstants.linesColor.cgColor
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Current User
    private let currentUser: User
    
    // MARK: - Loading Screen
    private var loadingVC: LoadingViewController?
    
    // MARK: - Initializer
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        
        setupUI()
        setupLayout()
        setupModule()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizedTexts), name: Notification.Name("LanguageDidChange"), object: nil)
    }
    
    // MARK: - Module Setup (VIP)
    private func setupModule() {
        let interactor = CreateSetInteractor(currentUser: currentUser)
        let presenter = CreateSetPresenter()
        let router = CreateSetRouter()
        
        self.interactor = interactor
        self.router = router
        
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        addBottomBorder(to: nameOfSetTextField)
        addBottomBorder(to: descriptionTextField)
    }
    
    private func addBottomBorder(to textField: UITextField) {
        let bottomLine = UIView()
        bottomLine.backgroundColor = ColorsLayoutConstants.linesColor
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: CreateSetConstants.textFieldBottomLineHeight)
        ])
    }
    
    private func setupLayout() {
        let rightStackView = UIStackView(arrangedSubviews: [saveButton])
        rightStackView.axis = .horizontal
        rightStackView.alignment = .center
        rightStackView.spacing = CreateSetConstants.stackViewRowSpacing
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let topStackView = UIStackView(arrangedSubviews: [closeButton, titleLabel, rightStackView])
        topStackView.axis = .horizontal
        topStackView.alignment = .center
        topStackView.distribution = .equalSpacing
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topStackView)
        
        let row1 = UIStackView(arrangedSubviews: [nameOfSetLabel, nameOfSetTextField])
        row1.axis = .vertical
        row1.spacing = CreateSetConstants.stackViewRowSpacing
        
        let row2 = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextField])
        row2.axis = .vertical
        row2.spacing = CreateSetConstants.stackViewRowSpacing
        
        let row3 = UIStackView(arrangedSubviews: [textOfSetLabel, textOfSetTextView])
        row3.axis = .vertical
        row3.spacing = CreateSetConstants.stackViewRowSpacing
        
        let fieldsStackView = UIStackView(arrangedSubviews: [row1, row2, row3])
        fieldsStackView.axis = .vertical
        fieldsStackView.spacing = CreateSetConstants.fieldsStackViewSpacing
        fieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fieldsStackView)
        
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CreateSetConstants.topStackViewTop),
            topStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CreateSetConstants.topStackViewSide),
            topStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CreateSetConstants.topStackViewSide),
            
            fieldsStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: CreateSetConstants.fieldsStackViewTop),
            fieldsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CreateSetConstants.fieldsStackViewSide),
            fieldsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CreateSetConstants.fieldsStackViewSide),
            
            textOfSetTextView.heightAnchor.constraint(equalToConstant: CreateSetConstants.textViewHeight)
        ])
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveTapped() {
        let nameOfSet = nameOfSetTextField.text ?? ""
        let desc = descriptionTextField.text ?? ""
        let textOfSet = textOfSetTextView.text ?? ""
        
        let request = CreateSet.Request(name: nameOfSet, description: desc, text: textOfSet)
        showLoading()
        interactor?.createSet(request: request)
    }
    
    @objc private func updateLocalizedTexts() {
        titleLabel.text = "сreatingset_label".localized
        nameOfSetLabel.text = "nameset_label".localized
        nameOfSetTextField.attributedPlaceholder = NSAttributedString(
            string: "name_label".localized,
            attributes: [.foregroundColor: ColorsLayoutConstants.linesColor]
        )
        descriptionLabel.text = "descriptionset_label".localized
        descriptionTextField.attributedPlaceholder = NSAttributedString(
            string: "description_label".localized,
            attributes: [.foregroundColor: ColorsLayoutConstants.linesColor]
        )
        textOfSetLabel.text = "textset_label".localized
    }
    
    // MARK: - Loading View Handling
    private func showLoading() {
        let loadingVC = LoadingViewController()
        loadingVC.modalPresentationStyle = .overFullScreen
        present(loadingVC, animated: false)
        self.loadingVC = loadingVC
    }
    
    private func hideLoading(completion: (() -> Void)? = nil) {
        loadingVC?.dismiss(animated: false, completion: completion)
        loadingVC = nil
    }
    
    // MARK: - Display Logic
    func displayCreateSet(viewModel: CreateSet.ViewModel) {
        let successKey = "set_create_sucess_message"
        let localizedSuccess = successKey.localized
        let isSuccess = viewModel.message == localizedSuccess
        let messageToShow = isSuccess ? localizedSuccess : viewModel.message

        loadingVC?.requestShowResult(
            message: messageToShow,
            isSuccess: isSuccess,
            onOK: { [weak self] in
                guard let self = self else { return }
                if isSuccess {
                    self.router?.routeToProfile(with: self.currentUser)
                } else {
                    self.loadingVC = nil
                }
            }
        )
    }
    
    // MARK: - Alert
    private func showAlert(message: String, title: String = "error_alert_title".localized, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
