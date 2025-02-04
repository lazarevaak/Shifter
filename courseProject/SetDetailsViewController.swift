import UIKit

class SetDetailsViewController: UIViewController {

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.red)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Name of the set of cards"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressCircle: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .green
        progress.trackTintColor = .lightGray
        progress.layer.cornerRadius = 10
        progress.clipsToBounds = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "64%"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .green
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let card1View: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.black.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let card1Label: UILabel = {
        let label = UILabel()
        label.text = "Card 1"
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let learnedCheckBox: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✓ Learned", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cardList: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        cardList.delegate = self
        cardList.dataSource = self
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(progressCircle)
        view.addSubview(progressLabel)
        view.addSubview(card1View)
        view.addSubview(cardList)
        view.addSubview(deleteButton)
        view.addSubview(changeButton)

        card1View.addSubview(card1Label)
        card1View.addSubview(learnedCheckBox)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            progressCircle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            progressCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressCircle.widthAnchor.constraint(equalToConstant: 100),
            progressCircle.heightAnchor.constraint(equalToConstant: 10),

            progressLabel.centerXAnchor.constraint(equalTo: progressCircle.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: progressCircle.bottomAnchor, constant: 5),

            card1View.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            card1View.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card1View.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            card1View.heightAnchor.constraint(equalToConstant: 80),

            card1Label.topAnchor.constraint(equalTo: card1View.topAnchor, constant: 10),
            card1Label.leadingAnchor.constraint(equalTo: card1View.leadingAnchor, constant: 10),

            learnedCheckBox.bottomAnchor.constraint(equalTo: card1View.bottomAnchor, constant: -10),
            learnedCheckBox.leadingAnchor.constraint(equalTo: card1View.leadingAnchor, constant: 10),

            cardList.topAnchor.constraint(equalTo: card1View.bottomAnchor, constant: 20),
            cardList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardList.heightAnchor.constraint(equalToConstant: 200),

            deleteButton.topAnchor.constraint(equalTo: cardList.bottomAnchor, constant: 20),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteButton.widthAnchor.constraint(equalToConstant: 100),
            deleteButton.heightAnchor.constraint(equalToConstant: 40),

            changeButton.topAnchor.constraint(equalTo: cardList.bottomAnchor, constant: 20),
            changeButton.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 20),
            changeButton.widthAnchor.constraint(equalToConstant: 100),
            changeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension SetDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Card \(indexPath.row + 1)"
        return cell
    }
}

