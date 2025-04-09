import UIKit

// MARK: - View Controller

final class SplashViewController: UIViewController {

    // MARK: - VIP Components

    var interactor: SplashBusinessLogic?
    var router: (SplashRoutingLogic & SplashDataPassing)?

    // MARK: - UI Elements

    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "ShifterIcon"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - External Properties

    weak var window: UIWindow?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVIP()
        configureUI()
        requestLoadInitialData()
    }

    // MARK: - Setup

    private func setupVIP() {
        let interactor = SplashInteractor()
        let presenter = SplashPresenter()
        let router = SplashRouter()

        self.interactor = interactor
        self.router = router

        interactor.presenter = presenter
        presenter.viewController = self

        router.viewController = self
        router.dataStore = interactor
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(iconView)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: SplashLayoutConstants.iconYOffset),
            iconView.widthAnchor.constraint(equalToConstant: SplashLayoutConstants.iconSize),
            iconView.heightAnchor.constraint(equalToConstant: SplashLayoutConstants.iconSize)
        ])
    }

    // MARK: - Business Logic Request

    private func requestLoadInitialData() {
        interactor?.loadInitialData(request: .init())
    }
}

// MARK: - Display Logic

extension SplashViewController: SplashDisplayLogic {
    func displayInitialData(viewModel: Splash.LoadInitialData.ViewModel) {
        switch viewModel.destination {
        case .profile(let user):
            router?.routeToProfile(user: user)
        case .signIn:
            router?.routeToSignIn()
        }
    }
}
