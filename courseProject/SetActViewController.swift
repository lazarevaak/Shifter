import UIKit

class SetActViewController: UIViewController {

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
        label.text = "Settings"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "Language of terms"
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let definitionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Language of definitions"
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let termsPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let definitionsPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(termsLabel)
        view.addSubview(termsPicker)
        view.addSubview(definitionsLabel)
        view.addSubview(definitionsPicker)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            termsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            termsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            termsPicker.topAnchor.constraint(equalTo: termsLabel.bottomAnchor, constant: 10),
            termsPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            termsPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            definitionsLabel.topAnchor.constraint(equalTo: termsPicker.bottomAnchor, constant: 20),
            definitionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            definitionsPicker.topAnchor.constraint(equalTo: definitionsLabel.bottomAnchor, constant: 10),
            definitionsPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            definitionsPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }
}
