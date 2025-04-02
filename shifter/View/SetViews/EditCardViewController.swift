import UIKit

// MARK: - Протокол делегата для кастомного экрана редактирования карточки
protocol EditCardViewControllerDelegate: AnyObject {
    func editCardViewController(_ controller: EditCardViewController, didUpdateCard card: Card)
}

// MARK: - Кастомный экран редактирования карточки (выезжает снизу)
class EditCardViewController: UIViewController {
    weak var delegate: EditCardViewControllerDelegate?
    var card: Card

    private let questionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Question"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let answerTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Answer"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(ColorsLayoutConstants.basicColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(ColorsLayoutConstants.additionalColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(card: Card) {
        self.card = card
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if let sheet = self.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customIdentifier = UISheetPresentationController.Detent.Identifier("custom")
                sheet.detents = [.custom(identifier: customIdentifier, resolver: { context in
                    return context.maximumDetentValue * 0.48
                })]
            } else {
                self.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
        }

        questionTextField.text = card.question
        answerTextField.text = card.answer

        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        setupLayout()
    }

    private func setupLayout() {
        view.addSubview(questionTextField)
        view.addSubview(answerTextField)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            questionTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            answerTextField.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 20),
            answerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            answerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 10),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func saveTapped() {
        card.question = questionTextField.text
        card.answer = answerTextField.text
        delegate?.editCardViewController(self, didUpdateCard: card)
        dismiss(animated: true, completion: nil)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}

