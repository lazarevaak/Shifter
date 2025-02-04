import UIKit

class SetsViewController: UIViewController {
    
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
    
    private let setsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let sets = ["Set 1", "Set 2", "Set 3", "Set 4", "Set 5", "Set 6"]

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.red)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(setsStackView)
        view.addSubview(backButton)

        for set in sets {
            let button = UIButton(type: .system)
            button.setTitle(set, for: .normal)
            button.backgroundColor = .lightGray
            button.layer.cornerRadius = 8
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            setsStackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            setsStackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            setsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            setsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }
}

