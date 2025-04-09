import UIKit
import CoreData

// MARK: - View Controller

final class EditCardSetViewController: UIViewController {

    // MARK: - Properties

    private let cardSet: CardSet
    weak var delegate: EditCardSetViewControllerDelegate?

    // MARK: - UI Elements

    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderWidth = 1
        tv.layer.borderColor = ColorsLayoutConstants.linesColor.cgColor
        tv.layer.cornerRadius = EditCardSetLayoutConstants.cornerRadius
        tv.font = UIFont.systemFont(ofSize: SizeLayoutConstants.textFieldFontSize)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("save_button_title".localized, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.layer.cornerRadius = EditCardSetLayoutConstants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    init(cardSet: CardSet) {
        self.cardSet = cardSet
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor

        view.addSubview(nameTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(saveButton)

        nameTextField.text = cardSet.name
        descriptionTextView.text = cardSet.setDescription

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        setupLayout()
    }

    // MARK: - Layout

    private func setupLayout() {
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: EditCardSetLayoutConstants.textFieldTop),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: EditCardSetLayoutConstants.horizontalInset),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -EditCardSetLayoutConstants.horizontalInset),
            nameTextField.heightAnchor.constraint(equalToConstant: EditCardSetLayoutConstants.textFieldHeight),

            descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor,
                                                     constant: EditCardSetLayoutConstants.textViewTop),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                         constant: EditCardSetLayoutConstants.horizontalInset),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                          constant: -EditCardSetLayoutConstants.horizontalInset),
            descriptionTextView.heightAnchor.constraint(equalToConstant: EditCardSetLayoutConstants.textViewHeight),

            saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor,
                                            constant: EditCardSetLayoutConstants.buttonTop),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: EditCardSetLayoutConstants.buttonWidth),
            saveButton.heightAnchor.constraint(equalToConstant: EditCardSetLayoutConstants.buttonHeight)
        ])
    }

    // MARK: - Localization

    @objc private func updateLocalizedTexts() {
        saveButton.setTitle("save_button_title".localized, for: .normal)
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        cardSet.name = nameTextField.text
        cardSet.setDescription = descriptionTextView.text

        if let context = cardSet.managedObjectContext {
            do {
                try context.save()
                delegate?.editCardSetViewController(self, didUpdateCardSet: cardSet)
                dismiss(animated: true, completion: nil)
            } catch {
                let alert = UIAlertController(title: "error_alert_title".localized,
                                              message: "Could not save changes.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true, completion: nil)
            }
        }
    }
}
