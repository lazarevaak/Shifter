import UIKit

// MARK: - ViewController

final class ResultsViewController: UIViewController, ResultsDisplayLogic {

    // MARK: - Public Properties
    var interactor: ResultsBusinessLogic?
    var router: ResultsRoutingLogic?
    var onDismiss: (() -> Void)?

    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        view.layer.cornerRadius = ResultsLayout.containerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.titleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let resultsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK".localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.buttonFontSize)
        button.tintColor = ColorsLayoutConstants.backgroundColor
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = ResultsLayout.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.baseTextColor.withAlphaComponent(0.5)
        setupViews()
        setupObservers()
        interactor?.fetchResults(request: Results.Fetch.Request())
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(resultsLabel)
        containerView.addSubview(dismissButton)

        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: ResultsLayout.containerWidthMultiplier),
            containerView.heightAnchor.constraint(equalToConstant: ResultsLayout.containerHeight),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ResultsLayout.topTitleSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ResultsLayout.sidePadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ResultsLayout.sidePadding),

            resultsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ResultsLayout.topResultSpacing),
            resultsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ResultsLayout.sidePadding),
            resultsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ResultsLayout.sidePadding),

            dismissButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ResultsLayout.bottomButtonSpacing),
            dismissButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: ResultsLayout.buttonWidth),
            dismissButton.heightAnchor.constraint(equalToConstant: ResultsLayout.buttonHeight)
        ])
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocalizedTexts),
            name: Notification.Name("LanguageDidChange"),
            object: nil
        )
    }

    // MARK: - Display Logic
    func displayResults(viewModel: Results.Fetch.ViewModel) {
        titleLabel.text = viewModel.titleText
        resultsLabel.text = viewModel.resultsText
        dismissButton.setTitle("OK".localized, for: .normal)
    }

    // MARK: - Actions
    @objc private func dismissTapped() {
        UIView.transition(
            with: containerView,
            duration: ResultsLayout.transitionDuration,
            options: [.transitionFlipFromLeft],
            animations: { self.containerView.alpha = 0 }
        ) { _ in
            self.router?.routeDismiss()
        }
    }

    @objc private func updateLocalizedTexts() {
        titleLabel.text = "allcardslearned_label".localized
        dismissButton.setTitle("OK".localized, for: .normal)
        interactor?.fetchResults(request: Results.Fetch.Request())
    }
}

// MARK: - Configuration

extension ResultsViewController {
    static func instantiate(
        leftScore: Int,
        rightScore: Int,
        progress: Int,
        onDismiss: @escaping () -> Void
    ) -> ResultsViewController {
        let vc = ResultsViewController()
        let interactor = ResultsInteractor()
        let presenter = ResultsPresenter()
        let router = ResultsRouter()

        vc.interactor = interactor
        vc.router = router
        vc.onDismiss = onDismiss

        interactor.presenter = presenter
        interactor.leftScore = leftScore
        interactor.rightScore = rightScore
        interactor.progress = progress

        presenter.viewController = vc
        router.viewController = vc

        vc.modalPresentationStyle = .overFullScreen
        return vc
    }
}
