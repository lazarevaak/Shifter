import UIKit
import CoreData

// MARK: - View Controller

final class SetsViewController: UIViewController {

    // MARK: - VIP

    var interactor: SetsBusinessLogic?
    var router: SetsRouter?

    // MARK: - Data

    private var displayedSets: [SetsModels.CardSetViewModel] = []

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "sets_label".localized
        label.font = UIFont.boldSystemFont(ofSize: SetsLayoutConstants.titleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "search_label".localized
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private let sortAscButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.up.circle")?
            .withTintColor(ColorsLayoutConstants.basicColor, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let sortDescButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.down.circle")?
            .withTintColor(ColorsLayoutConstants.basicColor, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private let setsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = SetsLayoutConstants.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.left")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    init(currentUser: User) {
        super.init(nibName: nil, bundle: nil)
        let interactor = SetsInteractor(currentUser: currentUser)
        let presenter = SetsPresenter()
        let router = SetsRouter()
        self.interactor = interactor
        self.router = router
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
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        setupLayout()
        setupActions()
        fetchSets()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizedTexts), name: .init("LanguageDidChange"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSets()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(backButton)

        let searchAndSortStack = UIStackView(arrangedSubviews: [searchBar, sortAscButton, sortDescButton])
        searchAndSortStack.axis = .horizontal
        searchAndSortStack.spacing = 8
        searchAndSortStack.alignment = .center
        searchAndSortStack.distribution = .fill
        searchAndSortStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchAndSortStack)

        view.addSubview(scrollView)
        scrollView.addSubview(setsStackView)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SetsLayoutConstants.backButtonTop),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetsLayoutConstants.sideInset),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SetsLayoutConstants.backButtonTop),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            searchAndSortStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: SetsLayoutConstants.searchTopSpacing),
            searchAndSortStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetsLayoutConstants.sideInset),
            searchAndSortStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetsLayoutConstants.sideInset),

            scrollView.topAnchor.constraint(equalTo: searchAndSortStack.bottomAnchor, constant: SetsLayoutConstants.searchTopSpacing),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetsLayoutConstants.sideInset),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetsLayoutConstants.sideInset),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: SetsLayoutConstants.scrollBottomInset),

            setsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            setsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            setsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            setsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            setsStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Setup

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        searchBar.delegate = self
        sortAscButton.addTarget(self, action: #selector(sortAscendingTapped), for: .touchUpInside)
        sortDescButton.addTarget(self, action: #selector(sortDescendingTapped), for: .touchUpInside)
    }

    // MARK: - Interactor Requests

    private func fetchSets() {
        interactor?.fetchSets(request: SetsModels.FetchSetsRequest())
    }

    private func performSearch(query: String) {
        interactor?.searchSets(request: SetsModels.SearchRequest(query: query))
    }

    // MARK: - Actions

    @objc private func sortAscendingTapped() {
        interactor?.sortSets(request: SetsModels.SortRequest(order: .ascending))
    }

    @objc private func sortDescendingTapped() {
        interactor?.sortSets(request: SetsModels.SortRequest(order: .descending))
    }

    @objc private func backTapped() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .reveal
        transition.subtype = .fromLeft
        view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false)
    }

    @objc private func updateLocalizedTexts() {
        titleLabel.text = "sets_label".localized
        searchBar.placeholder = "search_label".localized
    }

    // MARK: - Display Logic

    private func displaySets(_ sets: [SetsModels.CardSetViewModel]) {
        setsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        displayedSets = sets

        for (index, setVM) in sets.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(setVM.name, for: .normal)

            let progress = setVM.progressOfSet
            let backgroundColor: UIColor = {
                if progress < SetsLayoutConstants.progressLow {
                    return ColorsLayoutConstants.linesColor
                } else if progress < SetsLayoutConstants.progressMedium {
                    return ColorsLayoutConstants.specialTextColor
                } else {
                    return ColorsLayoutConstants.elementsColor
                }
            }()

            button.backgroundColor = backgroundColor
            button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
            button.layer.cornerRadius = SetsLayoutConstants.buttonCornerRadius
            button.heightAnchor.constraint(equalToConstant: SetsLayoutConstants.buttonHeight).isActive = true
            button.tag = index
            button.addTarget(self, action: #selector(openSetDetails(_:)), for: .touchUpInside)

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            button.addGestureRecognizer(longPress)

            setsStackView.addArrangedSubview(button)
        }
    }
}

// MARK: - UISearchBarDelegate

extension SetsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(query: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - User Interaction

extension SetsViewController {
    @objc private func openSetDetails(_ sender: UIButton) {
        guard sender.tag < displayedSets.count,
              let setsInteractor = interactor as? SetsInteractor,
              sender.tag < setsInteractor.availableSets.count else { return }

        let selectedSet = setsInteractor.availableSets[sender.tag]
        router?.routeToSetDetails(set: selectedSet)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let button = gesture.view as? UIButton,
              button.tag < displayedSets.count,
              let setsInteractor = interactor as? SetsInteractor,
              button.tag < setsInteractor.availableSets.count else { return }

        let setToDelete = setsInteractor.availableSets[button.tag]
        let alert = UIAlertController(
            title: "delete_set_title".localized,
            message: "delete_set_message".localizedWithArgs(setToDelete.name ?? "Untitled"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "logout_cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "delete_label".localized, style: .destructive, handler: { [weak self] _ in
            self?.interactor?.deleteSet(request: SetsModels.DeleteRequest(set: setToDelete))
            self?.fetchSets()
        }))
        present(alert, animated: true)
    }
}

// MARK: - SetsDisplayLogic

extension SetsViewController: SetsDisplayLogic {
    func displayFetchedSets(viewModel: SetsModels.FetchSetsViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.displaySets(viewModel.displayedSets)
        }
    }

    func displayError(message: String) {
        // Handle errors if needed
    }
}

// MARK: - Localization Helper

extension String {
    func localizedWithArgs(_ args: CVarArg...) -> String {
        let localizedString = self.localized
        return String(format: localizedString, arguments: args)
    }
}
