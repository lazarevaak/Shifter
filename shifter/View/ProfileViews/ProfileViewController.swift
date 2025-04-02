import UIKit
import CoreData


final class ProfileViewController: UIViewController, ProfileDisplayLogic {
    
    // MARK: - Clean Swift Components
    private var interactor: ProfileBusinessLogic?
    private var router: ProfileRoutingLogic?
    
    // MARK: - UI Элементы
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .label
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "User"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Your Settings", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        button.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Добавляем календарь – используем CalendarViewController, который инициализируется с context
    private let calendarView: CalendarViewController = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let cv = CalendarViewController(context: context)
        return cv
    }()
    
    // MARK: - Модель пользователя (Core Data объект)
    private var user: User
    
    // MARK: - Инициализация
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been реализован")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        
        view.addSubview(profileImageView)
        view.addSubview(userNameLabel)
        view.addSubview(settingsButton)
        view.addSubview(tabBarView)
        view.addSubview(calendarView)
        
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
        
        setupConstraints(stackView: stackView)
        setupModule()
        
        interactor?.fetchProfile(request: Profile.Request())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.fetchProfile(request: Profile.Request())
    }
    
    private func setupConstraints(stackView: UIStackView) {
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 16),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            calendarView.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 40),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            calendarView.heightAnchor.constraint(equalToConstant: 300),
            
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor, constant: -50),
            stackView.centerYAnchor.constraint(equalTo: tabBarView.centerYAnchor)
        ])
    }
    
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
    
    // MARK: - ProfileDisplayLogic
    func displayProfile(viewModel: Profile.ViewModel) {
        userNameLabel.text = viewModel.userName
        if let data = user.avatarData, let image = UIImage(data: data) {
            profileImageView.image = image
        }
    }
    
    // MARK: - Действия
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
        let avatarVC = AvatarSelectionViewController(user: user)
        avatarVC.onAvatarSelected = { [weak self] selectedImage in
            self?.profileImageView.image = selectedImage
        }
        let navController = UINavigationController(rootViewController: avatarVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
    }
}
