import UIKit
import CoreData
import os.log

// MARK: - StudyViewController

final class StudyViewController: UIViewController, StudyDisplayLogic {

    // MARK: - VIP Properties
    var interactor: StudyBusinessLogic?
    var router: StudyRouter?

    // MARK: - Data
    var cardSet: CardSet?
    private var menuItems: [StudyModels.MenuItemViewModel] = []

    // MARK: - UI Elements
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = UIColor.clear
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Initialization
    init(cardSet: CardSet?) {
        super.init(nibName: nil, bundle: nil)
        let interactor = StudyInteractor()
        let presenter = StudyPresenter()
        let router = StudyRouter()
        self.interactor = interactor
        self.router = router
        self.cardSet = cardSet
        router.cardSet = cardSet

        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YourDarkColor") ?? UIColor.systemBackground

        setupTableView()
        setupLayout()

        interactor?.fetchMenuItems(request: StudyModels.FetchMenuItemsRequest())
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StudyCell")
    }

    private func setupLayout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Display Logic
    func displayMenuItems(viewModel: StudyModels.FetchMenuItemsViewModel) {
        menuItems = viewModel.menuItems
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension StudyViewController: UITableViewDataSource, UITableViewDelegate {

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = menuItems[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "StudyCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        if let image = UIImage(systemName: item.iconName)?
            .withTintColor(ColorsLayoutConstants.basicColor, renderingMode: .alwaysOriginal) {
            config.image = image
            config.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        }
        config.text = item.title
        config.textProperties.color = ColorsLayoutConstants.specialTextColor

        cell.contentConfiguration = config
        cell.backgroundColor = UIColor(named: "YourDarkColor") ?? .systemBackground
        cell.selectionStyle = .none

        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menuItems[indexPath.row]
        router?.routeToNextScreen(for: item)
    }
}
