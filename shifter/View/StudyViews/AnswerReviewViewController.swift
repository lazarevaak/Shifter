import UIKit

// MARK: - ViewController

final class AnswerReviewViewController: UIViewController, AnswerReviewDisplayLogic {

    // MARK: - VIP Properties
    var interactor: AnswerReviewBusinessLogic?
    var router: (AnswerReviewRoutingLogic & AnswerReviewDataPassing)?

    // MARK: - Callbacks
    var onNext: (() -> Void)?

    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        view.layer.cornerRadius = AnswerLayout.containerCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: AnswerLayout.questionFontSize, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let answerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: AnswerLayout.answerFontSize, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorsLayoutConstants.specialTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let correctnessLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: AnswerLayout.correctnessFontSize)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("next_button".localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: AnswerLayout.buttonFontSize)
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = AnswerLayout.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.baseTextColor.withAlphaComponent(0.5)
        setupLayout()
        setupActions()
        interactor?.fetchResults(request: AnswerReview.FetchResults.Request())
    }

    // MARK: - Setup
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(questionLabel)
        containerView.addSubview(answerLabel)
        containerView.addSubview(correctnessLabel)
        containerView.addSubview(nextButton)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: AnswerLayout.containerWidthMultiplier),

            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: AnswerLayout.questionTopPadding),
            questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AnswerLayout.labelHorizontalPadding),
            questionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AnswerLayout.labelHorizontalPadding),

            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: AnswerLayout.labelVerticalSpacing),
            answerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AnswerLayout.labelHorizontalPadding),
            answerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AnswerLayout.labelHorizontalPadding),

            correctnessLabel.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: AnswerLayout.labelVerticalSpacing),
            correctnessLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AnswerLayout.labelHorizontalPadding),
            correctnessLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AnswerLayout.labelHorizontalPadding),

            nextButton.topAnchor.constraint(equalTo: correctnessLabel.bottomAnchor, constant: AnswerLayout.buttonTopPadding),
            nextButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: AnswerLayout.buttonWidth),
            nextButton.heightAnchor.constraint(equalToConstant: AnswerLayout.buttonHeight),
            nextButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -AnswerLayout.containerBottomPadding)
        ])
    }

    private func setupActions() {
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }

    // MARK: - Display Logic
    func displayResults(viewModel: AnswerReview.FetchResults.ViewModel) {
        questionLabel.text = viewModel.title
        answerLabel.text = viewModel.resultsText
    }

    // MARK: - Actions
    @objc private func nextTapped() {
        router?.routeToNext()
    }
}

// MARK: - Configuration

extension AnswerReviewViewController {
    static func instantiate(
        title: String,
        correctAnswers: Int,
        incorrectAnswers: Int,
        totalCards: Int,
        onNext: @escaping () -> Void
    ) -> AnswerReviewViewController {
        let viewController = AnswerReviewViewController()
        let interactor = AnswerReviewInteractor()
        let presenter = AnswerReviewPresenter()
        let router = AnswerReviewRouter()

        viewController.interactor = interactor
        viewController.router = router
        viewController.onNext = onNext

        interactor.presenter = presenter
        interactor.title = title
        interactor.correctAnswers = correctAnswers
        interactor.incorrectAnswers = incorrectAnswers
        interactor.totalCards = totalCards

        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor

        return viewController
    }
}
