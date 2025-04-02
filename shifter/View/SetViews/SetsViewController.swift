import UIKit
import CoreData

final class SetsViewController: UIViewController {
    
    // MARK: - Свойства текущего пользователя и наборов
    let currentUser: User
    private var allSets: [CardSet] = []
    private var filteredSets: [CardSet] = []
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sets"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
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
        return sv
    }()
    
    private let setsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
    
    // MARK: - Инициализация
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
        
        setupLayout()
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        searchBar.delegate = self
        sortAscButton.addTarget(self, action: #selector(sortAscendingTapped), for: .touchUpInside)
        sortDescButton.addTarget(self, action: #selector(sortDescendingTapped), for: .touchUpInside)
        
        fetchSetsForCurrentUser()
    }
    
    // MARK: - Размещение UI
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
        
        // Добавляем scrollView, в котором располагается stack view
        view.addSubview(scrollView)
        scrollView.addSubview(setsStackView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchAndSortStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchAndSortStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchAndSortStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: searchAndSortStack.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            setsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            setsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            setsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            setsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            setsStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    // MARK: - Загрузка данных из Core Data
    private func fetchSetsForCurrentUser() {
        if let userSets = currentUser.sets as? Set<CardSet> {
            allSets = Array(userSets)
        } else {
            allSets = []
        }
        filteredSets = allSets
        
        print("Найдено наборов: \(allSets.count)")
        displaySets(filteredSets)
    }
    
    // MARK: - Отображение наборов
    private func displaySets(_ sets: [CardSet]) {
        setsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, set) in sets.enumerated() {
            let button = UIButton(type: .system)
            let setName = set.name ?? "Untitled"
            button.setTitle(setName, for: .normal)
            button.backgroundColor = .systemGray4
            button.setTitleColor(ColorsLayoutConstants.buttonTextbackgroundColor, for: .normal)
            button.layer.cornerRadius = 8
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            button.tag = index
            button.addTarget(self, action: #selector(openSetDetails(_:)), for: .touchUpInside)
            
            setsStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Сортировка
    @objc private func sortAscendingTapped() {
        filteredSets.sort { ($0.name ?? "") < ($1.name ?? "") }
        displaySets(filteredSets)
    }
    
    @objc private func sortDescendingTapped() {
        filteredSets.sort { ($0.name ?? "") > ($1.name ?? "") }
        displaySets(filteredSets)
    }
    
    // MARK: - Действия
    @objc private func openSetDetails(_ sender: UIButton) {
        let index = sender.tag
        let selectedSet = filteredSets[index]
        
        let detailsVC = SetDetailsViewController(cardSet: selectedSet)
        detailsVC.modalPresentationStyle = .fullScreen
        present(detailsVC, animated: true, completion: nil)
    }
    
    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension SetsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if query.isEmpty {
            filteredSets = allSets
        } else {
            filteredSets = allSets.filter { cardSet in
                let nameLower = cardSet.name?.lowercased() ?? ""
                return nameLower.contains(query)
            }
        }
        
        displaySets(filteredSets)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
