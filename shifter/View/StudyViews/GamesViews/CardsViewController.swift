import UIKit

// MARK: - ViewController
final class CardsViewController: UIViewController, CardsDisplayLogic {
    var interactor: CardsBusinessLogic?
    var router: CardsRouter?
    
    private var leftScore: Int = 0 {
        didSet { leftScoreLabel.text = "\(leftScore)" }
    }
    private var rightScore: Int = 0 {
        didSet { rightScoreLabel.text = "\(rightScore)" }
    }
    
    private var isFrontSide = true
    
    // MARK: - UI Elements
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "cards_label".localized
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.testTextSize)
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.text = "0/0"
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.textTitleSize)
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.buttonColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    private let leftScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = ColorsLayoutConstants.buttonTextColor
        label.backgroundColor = ColorsLayoutConstants.basicColor
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = MemorizationConstants.cardLabelSize / 2
        label.layer.masksToBounds = true
        return label
    }()
    
    private let rightScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .bold)
        label.textColor = ColorsLayoutConstants.buttonTextColor
        label.backgroundColor = ColorsLayoutConstants.buttonColor
        label.textAlignment = .center
        label.layer.cornerRadius = MemorizationConstants.cardLabelSize / 2
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.cardLabelSize, weight: .medium)
        label.textColor = ColorsLayoutConstants.specialTextColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let leftOverlayLabel: UILabel = {
        let label = UILabel()
        label.text = "stillstudying_label".localized
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.overlayLabelSize)
        label.textColor = ColorsLayoutConstants.basicColor
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rightOverlayLabel: UILabel = {
        let label = UILabel()
        label.text = "studing_label".localized
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.overlayLabelSize)
        label.textColor = ColorsLayoutConstants.elementsColor
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var totalCards: Int {
        if let interactor = interactor as? CardsInteractor {
            return interactor.publicFlashcards.count
        }
        return 0
    }
    
    // MARK: - Инициализация VIP
    init(cardSet: CardSet) {
        super.init(nibName: nil, bundle: nil)
        let interactor = CardsInteractor(cardSet: cardSet)
        let presenter = CardsPresenter()
        let router = CardsRouter()
        self.interactor = interactor
        self.router = router
        
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }
    
    convenience init(cards: [Flashcard]) {
        let dummySet = CardSet()
        self.init(cardSet: dummySet)
        if let interactor = interactor as? CardsInteractor {
            interactor.setFlashcards(cards)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        
        setupLayout()
        setupActions()
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        interactor?.fetchCards(request: CardsModels.FetchCardsRequest())
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizedTexts), name: Notification.Name("LanguageDidChange"), object: nil)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(separatorLine)
        view.addSubview(leftScoreLabel)
        view.addSubview(counterLabel)
        view.addSubview(rightScoreLabel)
        view.addSubview(cardView)
        
        cardView.addSubview(cardLabel)
        cardView.addSubview(leftOverlayLabel)
        cardView.addSubview(rightOverlayLabel)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: CardsLayoutConstants.closeButtonTop),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CardsLayoutConstants.closeButtonLeading),
            closeButton.widthAnchor.constraint(equalToConstant: CardsLayoutConstants.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: CardsLayoutConstants.closeButtonSize),
            
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            separatorLine.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: CardsLayoutConstants.closeButtonTop),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: CardsLayoutConstants.separatorHeight),
            
            leftScoreLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: CardsLayoutConstants.closeButtonTop),
            leftScoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CardsLayoutConstants.closeButtonLeading),
            leftScoreLabel.widthAnchor.constraint(equalToConstant: MemorizationConstants.cardLabelSize),
            leftScoreLabel.heightAnchor.constraint(equalToConstant: MemorizationConstants.cardLabelSize),
            
            counterLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: CardsLayoutConstants.closeButtonTop),
            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            rightScoreLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: CardsLayoutConstants.closeButtonTop),
            rightScoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CardsLayoutConstants.closeButtonLeading),
            rightScoreLabel.widthAnchor.constraint(equalToConstant: MemorizationConstants.cardLabelSize),
            rightScoreLabel.heightAnchor.constraint(equalToConstant: MemorizationConstants.cardLabelSize),
            
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: CardsLayoutConstants.cardLabelHorizontalPadding),
            cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CardsLayoutConstants.cardViewWidthMultiplier),
            cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: CardsLayoutConstants.cardViewHeightMultiplier),
            
            cardLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            cardLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            cardLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: CardsLayoutConstants.cardLabelHorizontalPadding),
            cardLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -CardsLayoutConstants.cardLabelHorizontalPadding),
            
            leftOverlayLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            leftOverlayLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            rightOverlayLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            rightOverlayLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }
    
    // MARK: - Жесты и действия
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        cardView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        cardView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let offsetX = cardView.center.x - view.center.x
        
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: CardsLayoutConstants.panFadeDuration) {
                self.cardLabel.alpha = 0
            }
        case .changed:
            cardView.center = CGPoint(
                x: view.center.x + translation.x,
                y: view.center.y + translation.y
            )
            let threshold: CGFloat = CardsLayoutConstants.overlayThreshold
            let ratio = min(1, abs(offsetX) / threshold)
            if offsetX < 0 {
                leftOverlayLabel.alpha = ratio
                rightOverlayLabel.alpha = 0
            } else if offsetX > 0 {
                rightOverlayLabel.alpha = ratio
                leftOverlayLabel.alpha = 0
            } else {
                leftOverlayLabel.alpha = 0
                rightOverlayLabel.alpha = 0
            }
        case .ended:
            if offsetX < -CardsLayoutConstants.swipeThreshold {
                leftScore += 1
                interactor?.updateLearnedStatus(request: CardsModels.UpdateLearnedStatusRequest(isLearned: false))
                animateCardExit(direction: .left)
            } else if offsetX > CardsLayoutConstants.swipeThreshold {
                rightScore += 1
                interactor?.updateLearnedStatus(request: CardsModels.UpdateLearnedStatusRequest(isLearned: true))
                animateCardExit(direction: .right)
            } else {
                UIView.animate(withDuration: CardsLayoutConstants.exitAnimationDuration) {
                    self.cardView.center = self.view.center
                    self.leftOverlayLabel.alpha = 0
                    self.rightOverlayLabel.alpha = 0
                    self.cardLabel.alpha = 1
                }
            }
        default:
            break
        }
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        flipCard()
    }
    
    @objc private func updateLocalizedTexts() {
        leftOverlayLabel.text = "stillstudying_label".localized
        rightOverlayLabel.text = "studing_label".localized
        titleLabel.text = "cards_label".localized
    }
    
    private func flipCard() {
        UIView.transition(with: cardView,
                          duration: CardsLayoutConstants.flipAnimationDuration,
                          options: .transitionFlipFromRight,
                          animations: {
            self.cardLabel.text = self.isFrontSide ?
                (self.currentFlashcard?.answer ?? "") :
                (self.currentFlashcard?.question ?? "")
        }, completion: nil)
        isFrontSide.toggle()
    }
    
    private enum SwipeDirection {
        case left, right
    }
    
    private func animateCardExit(direction: SwipeDirection) {
        let offScreenX: CGFloat = direction == .left ? -view.bounds.width : view.bounds.width * 2
        
        UIView.animate(withDuration: 0.3, animations: {
            self.cardView.center.x = offScreenX
            self.cardView.alpha = 0
        }, completion: { _ in
            self.cardView.center = self.view.center
            self.cardView.alpha = 1
            self.cardLabel.alpha = 1
            self.leftOverlayLabel.alpha = 0
            self.rightOverlayLabel.alpha = 0
            self.moveToNextCard()
        })
    }
    
    private func moveToNextCard() {
        interactor?.moveToNextCard(request: CardsModels.NextCardRequest())
    }
    
    private var currentFlashcard: CardsModels.FlashcardViewModel? {
        if let interactor = interactor as? CardsInteractor,
           interactor.currentIndex < interactor.publicFlashcards.count {
            let flashcard = interactor.publicFlashcards[interactor.currentIndex]
            return CardsModels.FlashcardViewModel(question: flashcard.question, answer: flashcard.answer, isLearned: flashcard.isLearned)
        }
        return nil
    }
    
    // MARK: - CardsDisplayLogic

    func displayFetchedCards(viewModel: CardsModels.FetchCardsViewModel) {
        DispatchQueue.main.async {
            self.counterLabel.text = viewModel.progressText
            if let flashcardVM = viewModel.currentFlashcard {
                self.cardLabel.text = flashcardVM.question
                self.isFrontSide = true
            } else {
                self.cardLabel.text = ""
            }
        }
    }
    
    func displayNextCard(viewModel: CardsModels.FetchCardsViewModel) {
        DispatchQueue.main.async {
            self.counterLabel.text = viewModel.progressText
            if let interactor = self.interactor as? CardsInteractor,
               interactor.currentIndex < interactor.publicFlashcards.count {
                let flashcard = interactor.publicFlashcards[interactor.currentIndex]
                self.cardLabel.text = flashcard.question
                self.isFrontSide = true
            } else {
                let progress = (self.interactor as? CardsInteractor)?.cardSet?.progressOfSet ?? 0
                self.router?.routeToResults(leftScore: self.leftScore, rightScore: self.rightScore, progress: Int(progress))
            }
        }
    }
}
