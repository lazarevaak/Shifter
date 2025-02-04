import UIKit

class ProfileViewController: UIViewController {

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        button.setTitle("Your Settings >", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        return button
    }()
    
    private let tabBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let documentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.text"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openSetsScreen), for: .touchUpInside)
        return button
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openCreateSetScreen), for: .touchUpInside)
        return button
    }()

    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(profileImageView)
        view.addSubview(userNameLabel)
        view.addSubview(settingsButton)
        view.addSubview(tabBarView)

        let stackView = UIStackView(arrangedSubviews: [documentButton, addButton, profileButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        tabBarView.addSubview(stackView)

        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            userNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),

            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 16),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 50),

            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: 60),

            stackView.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor, constant: -50),
            stackView.centerYAnchor.constraint(equalTo: tabBarView.centerYAnchor)
        ])
    }

    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .fullScreen
        present(settingsVC, animated: true, completion: nil)
    }

    @objc private func openSetsScreen() {
        let setsVC = SetsViewController()
        setsVC.modalPresentationStyle = .fullScreen
        present(setsVC, animated: true, completion: nil)
    }

    @objc private func openCreateSetScreen() {
        let createSetVC = CreateSetViewController()
        createSetVC.modalPresentationStyle = .fullScreen
        present(createSetVC, animated: true, completion: nil)
    }
}
