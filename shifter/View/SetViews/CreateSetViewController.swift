import UIKit
import CoreData

protocol CreateSetDisplayLogic: AnyObject {
    func displayCreateSet(viewModel: CreateSet.ViewModel)
}

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
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "gearshape")?
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
        label.text = "Creating a set"
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.titleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameOfSetLabel: UILabel = {
        let label = UILabel()
        label.text = "Name of set"
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: LayoutConstants.labelFontSizeMedium, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameOfSetTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [.foregroundColor: ColorsLayoutConstants.additionalColor]
        )
        tf.font = UIFont.systemFont(ofSize: LayoutConstants.textFieldFontSize)
        return tf
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description of set"
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: LayoutConstants.labelFontSizeMedium, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.borderStyle = .none
        tf.attributedPlaceholder = NSAttributedString(
            string: "Description",
            attributes: [.foregroundColor: ColorsLayoutConstants.additionalColor]
        )
        tf.font = UIFont.systemFont(ofSize: LayoutConstants.textFieldFontSize)
        return tf
    }()
    
    private let textOfSetLabel: UILabel = {
        let label = UILabel()
        label.text = "Text of set"
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = UIFont.systemFont(ofSize: LayoutConstants.labelFontSizeMedium, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textOfSetTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: LayoutConstants.textViewFontSize)
        tv.layer.borderWidth = LayoutConstants.textViewBorderWidth
        tv.layer.borderColor = ColorsLayoutConstants.additionalColor.cgColor
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Layout Constants
    private enum LayoutConstants {
        static let topStackViewTop: CGFloat = 10
        static let topStackViewSide: CGFloat = 16
        static let fieldsStackViewTop: CGFloat = 45
        static let fieldsStackViewSide: CGFloat = 25
        static let textViewHeight: CGFloat = 300
        static let textFieldBottomLineHeight: CGFloat = 1
        static let stackViewRowSpacing: CGFloat = 10
        static let fieldsStackViewSpacing: CGFloat = 25
        static let textViewBorderWidth: CGFloat = 1
        
        static let labelFontSizeMedium: CGFloat = 14
        static let textFieldFontSize: CGFloat = 16
        static let textViewFontSize: CGFloat = 16
    }
    
    // MARK: - Текущий пользователь
    private let currentUser: User
    
    // MARK: - Инициализатор
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.buttonTextbackgroundColor
        
        setupUI()
        setupLayout()
        
        setupModule()
    }
    
    // MARK: - VIP Setup
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
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        addBottomBorder(to: nameOfSetTextField)
        addBottomBorder(to: descriptionTextField)
    }
    
    private func addBottomBorder(to textField: UITextField) {
        let bottomLine = UIView()
        bottomLine.backgroundColor = ColorsLayoutConstants.additionalColor
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: LayoutConstants.textFieldBottomLineHeight)
        ])
    }
    
    private func setupLayout() {
        let rightStackView = UIStackView(arrangedSubviews: [settingsButton, saveButton])
        rightStackView.axis = .horizontal
        rightStackView.alignment = .center
        rightStackView.spacing = LayoutConstants.stackViewRowSpacing
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let topStackView = UIStackView(arrangedSubviews: [closeButton, titleLabel, rightStackView])
        topStackView.axis = .horizontal
        topStackView.alignment = .center
        topStackView.distribution = .equalSpacing
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topStackView)
        
        let row1 = UIStackView(arrangedSubviews: [nameOfSetLabel, nameOfSetTextField])
        row1.axis = .vertical
        row1.spacing = LayoutConstants.stackViewRowSpacing
        
        let row2 = UIStackView(arrangedSubviews: [descriptionLabel, descriptionTextField])
        row2.axis = .vertical
        row2.spacing = LayoutConstants.stackViewRowSpacing
        
        let row3 = UIStackView(arrangedSubviews: [textOfSetLabel, textOfSetTextView])
        row3.axis = .vertical
        row3.spacing = LayoutConstants.stackViewRowSpacing
        
        let fieldsStackView = UIStackView(arrangedSubviews: [row1, row2, row3])
        fieldsStackView.axis = .vertical
        fieldsStackView.spacing = LayoutConstants.fieldsStackViewSpacing
        fieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fieldsStackView)
        
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.topStackViewTop),
            topStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.topStackViewSide),
            topStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.topStackViewSide),
            
            fieldsStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: LayoutConstants.fieldsStackViewTop),
            fieldsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.fieldsStackViewSide),
            fieldsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.fieldsStackViewSide),
            
            textOfSetTextView.heightAnchor.constraint(equalToConstant: LayoutConstants.textViewHeight)
        ])
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func settingsTapped() {
        let setActVC = SetActViewController()
        setActVC.modalPresentationStyle = .fullScreen
        present(setActVC, animated: true, completion: nil)
    }
    
    @objc private func saveTapped() {
        let nameOfSet = nameOfSetTextField.text ?? ""
        let desc = descriptionTextField.text ?? ""
        let textOfSet = textOfSetTextView.text ?? ""
        
        let request = CreateSet.Request(name: nameOfSet, description: desc, text: textOfSet)
        interactor?.createSet(request: request)
    }
    
    // MARK: - CreateSetDisplayLogic
    func displayCreateSet(viewModel: CreateSet.ViewModel) {
        if viewModel.message == "Set created successfully!" {
            router?.routeToProfile(with: currentUser)
        } else {
            showAlert(message: viewModel.message)
        }
    }
    
    // MARK: - Alert Helper
    private func showAlert(message: String, title: String = "Error", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
