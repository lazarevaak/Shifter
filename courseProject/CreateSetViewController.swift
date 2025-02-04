import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

class CreateSetViewController: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.orange)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "gearshape")?.withRenderingMode(.alwaysOriginal).withTintColor(.orange)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.orange)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Creating a set"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }

    private func setupLayout() {
        let topStackView = UIStackView(arrangedSubviews: [closeButton, titleLabel, saveButton])
        topStackView.axis = .horizontal
        topStackView.distribution = .equalSpacing
        topStackView.alignment = .center
        topStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topStackView)
        view.addSubview(settingsButton)

        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            topStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            settingsButton.centerYAnchor.constraint(equalTo: topStackView.centerYAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -10)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func settingsTapped() {
        let setActVC = SetActViewController()
        setActVC.modalPresentationStyle = .fullScreen
        present(setActVC, animated: true, completion: nil)
    }
}
