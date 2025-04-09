import UIKit
import CoreData

protocol MemorizationDisplayLogic: AnyObject {
    func displayCards(viewModel: Memorization.LoadCards.ViewModel)
    func displayOptionResult(viewModel: Memorization.LoadCards.ViewModel, isCorrect: Bool)
    func displayError(message: String)
    func displayFinishAlert(message: String)
}

final class MemorizationViewController: UIViewController, MemorizationDisplayLogic {
    
    // MARK: - Clean Swift VIP Свойства
    var interactor: MemorizationBusinessLogic?
    var router: MemorizationRoutingLogic?
    var cardSet: CardSet?
    
    private var lastTappedButton: UIButton?
    private var lastCardCorrectAnswer: String?
    
    // MARK: - UI: Верхняя панель и прочие элементы (дизайн не меняется)
    private let topBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = ColorsLayoutConstants.backgroundColor
        return v
    }()
    
    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark"), for: .normal)
        b.tintColor = ColorsLayoutConstants.basicColor
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return b
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "memorization_label".localized
        label.tintColor = ColorsLayoutConstants.specialTextColor
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.buttonColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private var optionButtons: [UIButton] = []
    
    // Для всплывающего окна при долгом нажатии
    private var longPressOverlay: UIView?
    
    // MARK: - Инициализация
    init(cardSet: CardSet) {
        self.cardSet = cardSet
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        
        setupLayout()
        setupCleanSwift()
        
        let request = Memorization.LoadCards.Request()
        interactor?.loadCards(request: request)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLocalizedTexts),
                                               name: Notification.Name("LanguageDidChange"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("LanguageDidChange"), object: nil)
    }
    
    private func setupCleanSwift() {
        let interactor = MemorizationInteractor()
        let presenter = MemorizationPresenter()
        let router = MemorizationRouter()
        
        self.interactor = interactor
        self.router = router
        
        interactor.presenter = presenter
        presenter.viewController = self
        presenter.router = router
        router.viewController = self  
        
        interactor.cardSet = self.cardSet
    }

    
    // MARK: - Layout (UI-элементы остаются без изменений)
    private func setupLayout() {
        view.addSubview(topBar)
        topBar.addSubview(closeButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(separatorLine)
        topBar.addSubview(progressStackView)
        view.addSubview(questionLabel)
        view.addSubview(optionsStackView)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: MemorizationConstants.topBarHeight),
            
            closeButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: MemorizationConstants.closeButtonLeading),
            closeButton.topAnchor.constraint(equalTo: topBar.topAnchor, constant: MemorizationConstants.closeButtonTop),
            
            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            separatorLine.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
            separatorLine.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: MemorizationConstants.separatorTopOffset),
            separatorLine.heightAnchor.constraint(equalToConstant: MemorizationConstants.separatorHeight),
            
            progressStackView.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: MemorizationConstants.closeButtonLeading),
            progressStackView.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -MemorizationConstants.closeButtonLeading),
            progressStackView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: MemorizationConstants.progressStackTopOffset + 16),
            progressStackView.heightAnchor.constraint(equalToConstant: MemorizationConstants.progressStackHeight),
            
            currentCardLabel.widthAnchor.constraint(equalToConstant: MemorizationConstants.cardLabelSize),
            currentCardLabel.heightAnchor.constraint(equalToConstant: MemorizationConstants.cardLabelSize),
            
            progressView.heightAnchor.constraint(equalToConstant: MemorizationConstants.progressViewHeight),
            
            questionLabel.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: MemorizationConstants.questionTopOffset),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: MemorizationConstants.questionHorizontalPadding),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -MemorizationConstants.questionHorizontalPadding),
            
            optionsStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: MemorizationConstants.optionsTopOffset),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: MemorizationConstants.optionsHorizontalPadding),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -MemorizationConstants.optionsHorizontalPadding)
        ])
        
        // Создаём кнопки вариантов ответа (до 4-х)
        for _ in 0..<4 {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.font = UIFont.systemFont(ofSize: SizeLayoutConstants.buttonFontSize)
            button.backgroundColor = ColorsLayoutConstants.backgroundColor
            button.setTitleColor(ColorsLayoutConstants.baseTextColor, for: .normal)
            button.layer.cornerRadius = MemorizationConstants.optionButtonCornerRadius
            button.layer.borderWidth = MemorizationConstants.optionButtonBorderWidth
            button.layer.borderColor = ColorsLayoutConstants.buttonColor.cgColor
            
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            button.addGestureRecognizer(longPress)
            
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: MemorizationConstants.optionButtonHeight)
            ])
            
            optionButtons.append(button)
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Обработка нажатий и обратной связи
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        // Сохраняем нажатую кнопку и корректный ответ предыдущей карточки
        self.lastTappedButton = sender
        let request = Memorization.OptionSelected.Request(selectedOption: sender.title(for: .normal) ?? "")
        interactor?.selectOption(request: request)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let button = gesture.view as? UIButton,
              let text = button.title(for: .normal) else { return }
        
        switch gesture.state {
        case .began:
            presentOptionPopup(from: button, with: text)
        case .ended, .cancelled:
            dismissLongPressPopup()
        default:
            break
        }
    }
    
    private func presentOptionPopup(from button: UIButton, with text: String) {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = ColorsLayoutConstants.linesColor.withAlphaComponent(0.5)
        overlay.alpha = 0.0
        view.addSubview(overlay)
        
        let buttonFrame = button.convert(button.bounds, to: view)
        
        let popupView = UIView()
        popupView.backgroundColor = ColorsLayoutConstants.backgroundColor
        popupView.layer.cornerRadius = 12
        popupView.clipsToBounds = true
        popupView.alpha = 0.0
        popupView.translatesAutoresizingMaskIntoConstraints = false
        
        overlay.addSubview(popupView)
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = ColorsLayoutConstants.specialTextColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            popupView.topAnchor.constraint(equalTo: overlay.topAnchor, constant: buttonFrame.origin.y),
            popupView.widthAnchor.constraint(equalTo: overlay.widthAnchor, multiplier: 0.9)
        ])
        
        longPressOverlay = overlay
        
        UIView.animate(withDuration: 0.3) {
            overlay.alpha = 1.0
            popupView.alpha = 1.0
        }
    }
    
    private func dismissLongPressPopup() {
        if let overlay = longPressOverlay {
            UIView.animate(withDuration: 0.3, animations: {
                overlay.alpha = 0.0
            }, completion: { _ in
                overlay.removeFromSuperview()
            })
            longPressOverlay = nil
        }
    }
    
    @objc private func updateLocalizedTexts() {
        titleLabel.text = "memorization_label".localized
    }
    
    // MARK: - MemorizationDisplayLogic
    
    func displayCards(viewModel: Memorization.LoadCards.ViewModel) {
        guard let cardVM = viewModel.displayCards.first else { return }
        
        questionLabel.text = cardVM.question
        currentCardLabel.text = "\(viewModel.currentIndex)"
        totalCardLabel.text = "\(viewModel.totalCount)"
        progressView.setProgress(viewModel.progress, animated: true)
        
        self.lastCardCorrectAnswer = cardVM.correctAnswer
        
        for (index, button) in optionButtons.enumerated() {
            button.backgroundColor = ColorsLayoutConstants.backgroundColor
            button.setTitleColor(ColorsLayoutConstants.baseTextColor, for: .normal)
            if index < cardVM.options.count {
                button.setTitle(cardVM.options[index], for: .normal)
                button.isHidden = false
            } else {
                button.setTitle(nil, for: .normal)
                button.isHidden = true
            }
        }
    }
    
    func displayOptionResult(viewModel: Memorization.LoadCards.ViewModel, isCorrect: Bool) {
        if let tappedButton = lastTappedButton {
            if isCorrect {
                tappedButton.backgroundColor = ColorsLayoutConstants.correctanswerColor
                tappedButton.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
            } else {
                tappedButton.backgroundColor = ColorsLayoutConstants.incorrectanswerColor
                tappedButton.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
                if let correctAnswer = lastCardCorrectAnswer {
                    for button in optionButtons {
                        if button.title(for: .normal) == correctAnswer {
                            button.backgroundColor = ColorsLayoutConstants.correctanswerColor
                            button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
                            break
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.lastTappedButton = nil
            self.lastCardCorrectAnswer = nil
            self.displayCards(viewModel: viewModel)
        }
    }
    
    func displayError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    func displayFinishAlert(message: String) {
        let alert = UIAlertController(title: "Результаты", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true)
    }
}
