import UIKit

final class TestViewController: UIViewController, TestDisplayLogic {

    // MARK: - VIP компоненты
    var interactor: TestBusinessLogic?
    var router: TestRoutingLogic?
    var cardSet: CardSet?

    // MARK: - UI Элементы
    private let topBarView = UIView()
    private let closeButton = UIButton(type: .system)

    private let currentCardLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textColor = ColorsLayoutConstants.buttonTextColor
        label.backgroundColor = ColorsLayoutConstants.basicColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = MemorizationConstants.cardLabelSize / 2
        label.layer.masksToBounds = true
        return label
    }()

    private let totalCardLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.progressTintColor = ColorsLayoutConstants.basicColor
        pv.trackTintColor = ColorsLayoutConstants.progressColor
        pv.layer.cornerRadius = 4
        pv.clipsToBounds = true
        return pv
    }()

    private lazy var progressStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [currentCardLabel, progressView, totalCardLabel])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 8
        sv.distribution = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let topSeparator = UIView()

    private let testTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "test_label".localized
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.testTextSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.testTextSize, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let answerTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "enteranswer_label".localized
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("check_label".localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.textTitleSize)
        button.setTitleColor(ColorsLayoutConstants.basicColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [questionLabel, answerTextField, checkButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Инициализация
    init(cardSet: CardSet) {
        self.cardSet = cardSet
        super.init(nibName: nil, bundle: nil)
        setupVIP()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been реализован")
    }

    private func setupVIP() {
        let interactor = TestInteractor(cardSet: cardSet)
        let presenter = TestPresenter()
        let router = TestRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        layoutUI()

        interactor?.viewDidLoad(request: TestModels.TestRequest())

        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizedTexts), name: Notification.Name("LanguageDidChange"), object: nil)
    }

    // MARK: - Настройка UI
    private func setupUI() {
        setupTopBar()
        view.addSubview(progressStackView)
        view.addSubview(contentStackView)
        checkButton.addTarget(self, action: #selector(checkAnswerTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupTopBar() {
        topBarView.backgroundColor = ColorsLayoutConstants.backgroundColor
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = ColorsLayoutConstants.basicColor
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        topBarView.addSubview(closeButton)

        topBarView.addSubview(testTitleLabel)

        topSeparator.backgroundColor = ColorsLayoutConstants.linesColor
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topSeparator)
    }

    private func layoutUI() {
        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: guide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 44),

            closeButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: GamesConstants.buttonSize),
            closeButton.heightAnchor.constraint(equalToConstant: GamesConstants.buttonSize),

            testTitleLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            testTitleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),

            topSeparator.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),

            progressStackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: MemorizationConstants.closeButtonLeading),
            progressStackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -MemorizationConstants.closeButtonLeading),
            progressStackView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: MemorizationConstants.progressStackTopOffset + 16),
            progressStackView.heightAnchor.constraint(equalToConstant: MemorizationConstants.progressStackHeight),

            currentCardLabel.widthAnchor.constraint(equalToConstant: MemorizationConstants.cardLabelSize),
            currentCardLabel.heightAnchor.constraint(equalToConstant: MemorizationConstants.cardLabelSize),

            progressView.heightAnchor.constraint(equalToConstant: MemorizationConstants.progressViewHeight),

            contentStackView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 40),
            contentStackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -40),

            checkButton.heightAnchor.constraint(equalToConstant: SizeLayoutConstants.editHeightAnchorSize)
        ])
    }

    // MARK: - Actions
    @objc private func checkAnswerTapped() {
        let userAnswer = answerTextField.text ?? ""
        interactor?.checkAnswer(request: TestModels.CheckAnswerRequest(userAnswer: userAnswer))
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func updateLocalizedTexts() {
        testTitleLabel.text = "test_label".localized
        answerTextField.placeholder = "enteranswer_label".localized
        checkButton.setTitle("check_label".localized, for: .normal)
    }

    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Display Logic
    func displayTest(viewModel: TestModels.TestViewModel) {
        if viewModel.isTestCompleted {
            let progressPercent = viewModel.totalCards > 0
                ? Int(Float(viewModel.correctAnswers) / Float(viewModel.totalCards) * 100)
                : 0

            let resultsVC = ResultsViewController.instantiate(
                leftScore: viewModel.totalCards - viewModel.correctAnswers,
                rightScore: viewModel.correctAnswers,
                progress: progressPercent
            ) { [weak self] in
                // после закрытия экрана результатов закрываем тестовый экран
                self?.dismiss(animated: true, completion: nil)
            }

            present(resultsVC, animated: true)
        } else {
            questionLabel.text = viewModel.questionText
            answerTextField.text = ""
            currentCardLabel.text = viewModel.currentIndexText
            totalCardLabel.text = "\(viewModel.totalCards)"
            progressView.setProgress(viewModel.progress, animated: true)
        }
    }



    func displayAnswer(viewModel: TestModels.CheckAnswerViewModel) {
        let answerReviewVC = AnswerReviewViewController.instantiate(
            title: viewModel.alertTitle,
            correctAnswers: viewModel.correctAnswers,
            incorrectAnswers: viewModel.incorrectAnswers,
            totalCards: viewModel.totalCards
        ) { [weak self] in
            // по нажатию «Next» перезапускаем тест
            self?.interactor?.viewDidLoad(request: TestModels.TestRequest())
        }
        answerReviewVC.modalPresentationStyle = .overFullScreen
        present(answerReviewVC, animated: true)
    }
}
