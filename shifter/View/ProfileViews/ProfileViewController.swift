import UIKit
import CoreData

// MARK: - ViewController
final class ProfileViewController: UIViewController, ProfileDisplayLogic {

    // MARK: - Clean Swift Components
    private var interactor: ProfileBusinessLogic?
    private var router: ProfileRoutingLogic?

    // MARK: - UI Elements
    private let topDividerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle")
        iv.tintColor = .label
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.cornerRadius = ProfileLayout.profileImageSize / 2
        iv.isUserInteractionEnabled = true
        return iv
    }()

    private let textFieldUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.overlayLabelSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("your_settings_title".localized, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.buttonColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let dividerSettingsCalendar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.secondaryLabel.cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let documentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.text"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Calendar Child Controller
    private let calendarVC: CalendarViewController = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return CalendarViewController(context: context)
    }()

    // MARK: - User Model
    private var user: User

    // MARK: - Initialization
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true

        setupUI()
        addCalendarChild()
        setupModule()
        interactor?.fetchProfile(request: Profile.Request())

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLocalizedTexts),
                                               name: Notification.Name("LanguageDidChange"),
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.fetchProfile(request: Profile.Request())
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(topDividerView)
        view.addSubview(profileImageView)
        view.addSubview(userNameLabel)
        view.addSubview(textFieldUnderline)
        view.addSubview(settingsButton)
        view.addSubview(dividerSettingsCalendar)
        view.addSubview(tabBarView)

        let stackView = UIStackView(arrangedSubviews: [documentButton, addButton, profileButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tabBarView.addSubview(stackView)

        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        documentButton.addTarget(self, action: #selector(openSetsScreen), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(openCreateSetScreen), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        profileImageView.addGestureRecognizer(tapGesture)

        setupConstraints(stackView)
    }

    private func setupConstraints(_ stackView: UIStackView) {
        NSLayoutConstraint.activate([
            topDividerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topDividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topDividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topDividerView.heightAnchor.constraint(equalToConstant: ProfileLayout.dividerHeight),

            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: topDividerView.bottomAnchor, constant: ProfileLayout.profileImageTopSpacing),
            profileImageView.widthAnchor.constraint(equalToConstant: ProfileLayout.profileImageSize),
            profileImageView.heightAnchor.constraint(equalToConstant: ProfileLayout.profileImageSize),

            userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: ProfileLayout.labelTopSpacing),

            textFieldUnderline.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: ProfileLayout.labelTopSpacing),
            textFieldUnderline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ProfileLayout.horizontalPadding),
            textFieldUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ProfileLayout.horizontalPadding),
            textFieldUnderline.heightAnchor.constraint(equalToConstant: ProfileLayout.dividerHeight),

            settingsButton.topAnchor.constraint(equalTo: textFieldUnderline.bottomAnchor, constant: ProfileLayout.labelTopSpacing),
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: ProfileLayout.settingsButtonWidth),
            settingsButton.heightAnchor.constraint(equalToConstant: ProfileLayout.settingsButtonHeight),

            dividerSettingsCalendar.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: ProfileLayout.labelTopSpacing),
            dividerSettingsCalendar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ProfileLayout.horizontalPadding),
            dividerSettingsCalendar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ProfileLayout.horizontalPadding),
            dividerSettingsCalendar.heightAnchor.constraint(equalToConstant: ProfileLayout.dividerHeight),

            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: ProfileLayout.tabBarHeight),

            stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor, constant: ProfileLayout.tabBarSideInset),
            stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor, constant: -ProfileLayout.tabBarSideInset),
            stackView.centerYAnchor.constraint(equalTo: tabBarView.centerYAnchor)
        ])
    }

    private func addCalendarChild() {
        addChild(calendarVC)
        view.addSubview(calendarVC.view)
        calendarVC.view.translatesAutoresizingMaskIntoConstraints = false
   
        NSLayoutConstraint.activate([
            calendarVC.view.topAnchor.constraint(equalTo: dividerSettingsCalendar.bottomAnchor, constant: ProfileLayout.labelTopSpacing),
            calendarVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ProfileLayout.horizontalPadding),
            calendarVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -ProfileLayout.horizontalPadding),
            calendarVC.view.heightAnchor.constraint(equalToConstant: ProfileLayout.calendarHeight)
        ])
        
        calendarVC.didMove(toParent: self)
    }

    // MARK: - Module Setup
    private func setupModule() {
        let interactor = ProfileInteractor(user: user)
        let presenter = ProfilePresenter()
        let router = ProfileRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }

    // MARK: - Display Logic
    func displayProfile(viewModel: Profile.ViewModel) {
        userNameLabel.text = viewModel.userName
        if let data = user.avatarData, let image = UIImage(data: data) {
            profileImageView.image = image
        }
    }

    // MARK: - Actions
    @objc private func settingsTapped() {
        router?.routeToSettings(with: user)
    }

    @objc private func openSetsScreen() {
        router?.routeToSetsScreen(with: user)
    }

    @objc private func openCreateSetScreen() {
        router?.routeToCreateSet(with: user)
    }

    @objc private func avatarTapped() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let avatarVC = AvatarSelectionViewController(user: user, context: context)
        avatarVC.onAvatarSelected = { [weak self] selectedImage in
            self?.profileImageView.image = selectedImage
        }
        let navController = UINavigationController(rootViewController: avatarVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
    }

    @objc private func updateLocalizedTexts() {
        settingsButton.setTitle("your_settings_title".localized, for: .normal)
    }
}
