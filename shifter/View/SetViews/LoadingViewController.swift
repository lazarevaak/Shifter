import UIKit
import CoreData

// MARK: - View Controller

final class LoadingViewController: UIViewController {

    // MARK: - VIP Components

    var interactor: LoadingBusinessLogic?
    var router: (LoadingRoutingLogic & LoadingDataPassing)?

    // MARK: - UI Elements

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = ColorsLayoutConstants.basicColor
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "creatingyourset_label".localized
        label.textAlignment = .center
        label.textColor = ColorsLayoutConstants.basicColor
        label.font = .systemFont(ofSize: SizeLayoutConstants.textFieldFontSize, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let okButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.tintColor = ColorsLayoutConstants.buttonTextColor
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.titleLabel?.font = .systemFont(ofSize: SizeLayoutConstants.textTitleSize, weight: .bold)
        button.isHidden = true
        button.layer.cornerRadius = LoadingLayoutConstants.buttonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var onOKTapped: (() -> Void)?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVIP()
        configureUI()
        setupActions()
        setupLocalizationObserver()
    }

    // MARK: - Setup

    private func setupVIP() {
        let interactor = LoadingInteractor()
        let presenter = LoadingPresenter()
        let router = LoadingRouter()

        self.interactor = interactor
        self.router = router

        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
        router.dataStore = interactor
    }

    private func configureUI() {
        view.backgroundColor = ColorsLayoutConstants.linesColor.withAlphaComponent(0.4)
        view.addSubview(containerView)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(loadingLabel)
        containerView.addSubview(okButton)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: LoadingLayoutConstants.containerWidth),
            containerView.heightAnchor.constraint(equalToConstant: LoadingLayoutConstants.containerHeight),

            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: LoadingLayoutConstants.indicatorTop),

            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: LoadingLayoutConstants.labelTopSpacing),
            loadingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: LoadingLayoutConstants.labelHorizontalInset),
            loadingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -LoadingLayoutConstants.labelHorizontalInset),

            okButton.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: LoadingLayoutConstants.buttonTopSpacing),
            okButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            okButton.widthAnchor.constraint(equalToConstant: LoadingLayoutConstants.buttonWidth),
            okButton.heightAnchor.constraint(equalToConstant: LoadingLayoutConstants.buttonHeight),
            okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: LoadingLayoutConstants.buttonBottomSpacing)
        ])
    }

    private func setupActions() {
        okButton.addTarget(self, action: #selector(okTapped), for: .touchUpInside)
    }

    private func setupLocalizationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateLocalizedTexts),
            name: Notification.Name("LanguageDidChange"),
            object: nil
        )
    }

    // MARK: - User Actions

    @objc private func okTapped() {
        dismiss(animated: false) {
            self.onOKTapped?()
        }
    }

    @objc private func updateLocalizedTexts() {
        loadingLabel.text = "creatingyourset_label".localized
    }
}

// MARK: - Display Logic

extension LoadingViewController: LoadingDisplayLogic {
    func displayShowResult(viewModel: Loading.ShowResult.ViewModel) {
        activityIndicator.stopAnimating()
        loadingLabel.text = viewModel.message
        okButton.isHidden = false
    }
}

// MARK: - Requests to Interactor

extension LoadingViewController {
    func requestShowResult(message: String, isSuccess: Bool, onOK: @escaping () -> Void) {
        self.onOKTapped = onOK
        let request = Loading.ShowResult.Request(message: message, isSuccess: isSuccess)
        interactor?.showResult(request: request)
    }
}
