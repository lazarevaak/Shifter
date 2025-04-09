import UIKit
import CoreData
import OSLog
import Foundation

// MARK: - View Controller

final class EditCardViewController: UIViewController, EditCardDisplayLogic {

    // MARK: - VIP Components

    var interactor: EditCardBusinessLogic?
    var router: EditCardRoutingLogic?

    // MARK: - Data

    private var card: Card

    // MARK: - UI Elements

    private lazy var questionTextView: UITextView = {
        let tv = UITextView()
        tv.text = "question_label".localized
        tv.font = UIFont.systemFont(ofSize: SizeLayoutConstants.textFieldFontSize)
        tv.layer.borderColor = ColorsLayoutConstants.linesColor.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = EditCardLayoutConstants.cornerRadius
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var answerTextView: UITextView = {
        let tv = UITextView()
        tv.text = "answer_label".localized
        tv.font = UIFont.systemFont(ofSize: SizeLayoutConstants.textFieldFontSize)
        tv.layer.borderColor = ColorsLayoutConstants.linesColor.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = EditCardLayoutConstants.cornerRadius
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("save_button_title".localized, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.layer.cornerRadius = EditCardLayoutConstants.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    init(card: Card) {
        self.card = card
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        setupModule()
        setupLayout()
        setupActions()
        populateFields()
    }

    // MARK: - Setup

    private func setupModule() {
        let interactor = EditCardInteractor(card: card)
        let presenter = EditCardPresenter()
        let router = EditCardRouter()

        self.interactor = interactor
        self.router = router

        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }

    private func setupLayout() {
        view.addSubview(questionTextView)
        view.addSubview(answerTextView)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            questionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                  constant: EditCardLayoutConstants.verticalSpacing),
            questionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: EditCardLayoutConstants.horizontalInset),
            questionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -EditCardLayoutConstants.horizontalInset),
            questionTextView.heightAnchor.constraint(equalToConstant: EditCardLayoutConstants.textViewHeight),

            answerTextView.topAnchor.constraint(equalTo: questionTextView.bottomAnchor,
                                                constant: EditCardLayoutConstants.verticalSpacing),
            answerTextView.leadingAnchor.constraint(equalTo: questionTextView.leadingAnchor),
            answerTextView.trailingAnchor.constraint(equalTo: questionTextView.trailingAnchor),
            answerTextView.heightAnchor.constraint(equalToConstant: EditCardLayoutConstants.textViewHeight),

            saveButton.topAnchor.constraint(equalTo: answerTextView.bottomAnchor,
                                            constant: EditCardLayoutConstants.verticalSpacing),
            saveButton.leadingAnchor.constraint(equalTo: answerTextView.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: answerTextView.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: EditCardLayoutConstants.buttonHeight),
        ])
    }

    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    private func populateFields() {
        questionTextView.text = card.question
        answerTextView.text = card.answer
    }

    // MARK: - User Actions

    @objc private func saveTapped() {
        let newQuestion = questionTextView.text ?? ""
        let newAnswer = answerTextView.text ?? ""

        let request = EditCard.UpdateCard.Request(
            question: newQuestion,
            answer: newAnswer
        )
        interactor?.updateCard(request: request)
    }

    // MARK: - Display Logic

    func displayUpdatedCard(viewModel: EditCard.UpdateCard.ViewModel) {
        router?.routeToPreviousScreen()
    }
}
