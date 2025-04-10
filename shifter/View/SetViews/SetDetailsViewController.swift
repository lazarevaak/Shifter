import UIKit
import CoreData
import Compression
import os.log

// MARK: - SetDetailsViewController
class SetDetailsViewController: UIViewController {

    // MARK: - Свойства
    private let cardSet: CardSet
    var isDownloadMode: Bool = false

    private lazy var fetchedResultsController: NSFetchedResultsController<Card> = {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "set == %@", cardSet)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "question", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    private var cards: [Card] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    private var currentCardIndex = 0
    private var isFrontSide = true

    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.example.app", category: "SetDetailsViewController")

    private var context: NSManagedObjectContext {
        return cardSet.managedObjectContext ?? (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - UI Элементы

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "square.and.arrow.up")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.down.to.line")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let lockButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "lock.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: SetDetailsConstants.titleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.linesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let editCardSetButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "ellipsis")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: SizeLayoutConstants.buttonFontSize, weight: .medium))
        button.setImage(image, for: .normal)
        button.transform = CGAffineTransform(rotationAngle: .pi / 2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let progressContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let backgroundCircle = CAShapeLayer()
    private let progressCircle = CAShapeLayer()
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.font = UIFont.boldSystemFont(ofSize: SetDetailsConstants.progressFontSize)
        label.textColor = ColorsLayoutConstants.basicColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorsLayoutConstants.elementsColor
        label.font = UIFont.systemFont(ofSize: SetDetailsConstants.descriptionFontSize)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let textOfSetLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.font = UIFont.systemFont(ofSize: SetDetailsConstants.cardFontSize)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Флеш-карта (flip-контейнер)
    private let flipContainerView: UIView = {
        let v = UIView()
        v.layer.borderWidth = SetDetailsConstants.flipContainerBorderWidth
        v.layer.cornerRadius = SetDetailsConstants.flipContainerCornerRadius
        v.layer.borderColor = ColorsLayoutConstants.baseTextColor.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let frontSideView: UIView = {
        let v = UIView()
        v.backgroundColor = ColorsLayoutConstants.buttonTextColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let frontSideLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.font = UIFont.systemFont(ofSize: SetDetailsConstants.cardFontSize)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let backSideView: UIView = {
        let v = UIView()
        v.backgroundColor = ColorsLayoutConstants.buttonTextColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let backSideLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorsLayoutConstants.baseTextColor
        label.font = UIFont.systemFont(ofSize: SetDetailsConstants.cardFontSize)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let learnedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("learned_label".localized, for: .normal)
        button.tintColor = ColorsLayoutConstants.basicColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("◀︎", for: .normal)
        button.tintColor = ColorsLayoutConstants.buttonColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: SetDetailsConstants.arrowButtonFontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("▶︎", for: .normal)
        button.tintColor = ColorsLayoutConstants.buttonColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: SetDetailsConstants.arrowButtonFontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let deleteCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("deletecard_label".localized, for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cardList: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("delete_label".localized, for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("change_label".localized, for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.specialTextColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let studyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("study_label".localized, for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.specialTextColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Инициализатор
    init(cardSet: CardSet) {
        self.cardSet = cardSet
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        
        cardList.delegate = self
        cardList.dataSource = self
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevCard), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextCard), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(changeCardTapped), for: .touchUpInside)
        studyButton.addTarget(self, action: #selector(studyTapped), for: .touchUpInside)
        learnedButton.addTarget(self, action: #selector(learnedButtonTapped), for: .touchUpInside)
        deleteCardButton.addTarget(self, action: #selector(deleteCurrentCard), for: .touchUpInside)
        
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        lockButton.addTarget(self, action: #selector(lockTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        flipContainerView.addGestureRecognizer(tapGesture)
        
        // Добавляем кнопку редактирования набора в иерархию view
        view.addSubview(editCardSetButton)
        editCardSetButton.addTarget(self, action: #selector(editCardSetTapped), for: .touchUpInside)
        
        setupLayout()
        setupProgressRing()
        
        titleLabel.text = cardSet.name ?? "Untitled"
        descriptionLabel.text = cardSet.setDescription ?? ""
        textOfSetLabel.text = cardSet.textOfSet ?? ""
        
        if isDownloadMode {
            shareButton.isHidden = true
            downloadButton.isHidden = false
            
            let image = UIImage(systemName: "xmark")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(ColorsLayoutConstants.basicColor)
            
            backButton.setImage(image, for: .normal)
            backButton.setTitle(nil, for: .normal)
        } else {
            shareButton.isHidden = false
            downloadButton.isHidden = true
            backButton.setTitle(nil, for: .normal)
            
            let image = UIImage(systemName: "arrow.left")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(ColorsLayoutConstants.basicColor)
            
            backButton.setImage(image, for: .normal)
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            os_log("Ошибка загрузки карточек: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
        
        updateLockButtonUI()
        updateFlashcardView()
        updateProgressUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizedTexts), name: Notification.Name("LanguageDidChange"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
            currentCardIndex = 0
            updateFlashcardView()
            updateProgressUI()
        } catch {
            os_log("Ошибка обновления карточек: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Layout Setup
    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(shareButton)
        view.addSubview(downloadButton)
        view.addSubview(lockButton)
        view.addSubview(titleLabel)
        view.addSubview(titleUnderline)
        view.addSubview(progressContainerView)
        progressContainerView.addSubview(progressLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(textOfSetLabel)
        view.addSubview(flipContainerView)
        flipContainerView.addSubview(frontSideView)
        flipContainerView.addSubview(backSideView)
        frontSideView.addSubview(frontSideLabel)
        backSideView.addSubview(backSideLabel)
        backSideView.addSubview(learnedButton)
        view.addSubview(prevButton)
        view.addSubview(nextButton)
        view.addSubview(deleteCardButton)
        view.addSubview(cardList)
        view.addSubview(deleteButton)
        view.addSubview(changeButton)
        view.addSubview(studyButton)
        
        NSLayoutConstraint.activate([
            editCardSetButton.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor, constant: 10),
            editCardSetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            editCardSetButton.widthAnchor.constraint(equalToConstant: 28),
            editCardSetButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SetDetailsConstants.topSafeAreaMargin),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.backButtonLeading),
            
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.backButtonLeading),
            downloadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.backButtonLeading),
            
            lockButton.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
            lockButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SetDetailsConstants.topSafeAreaMargin),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleUnderline.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            titleUnderline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            titleUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            titleUnderline.heightAnchor.constraint(equalToConstant: 0.5),
            
            progressContainerView.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor, constant: SetDetailsConstants.progressContainerTopMargin),
            progressContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressContainerView.widthAnchor.constraint(equalToConstant: SetDetailsConstants.progressContainerSize),
            progressContainerView.heightAnchor.constraint(equalToConstant: SetDetailsConstants.progressContainerSize),
            
            progressLabel.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: SetDetailsConstants.descriptionTopMargin),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            
            textOfSetLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: SetDetailsConstants.textOfSetTopMargin),
            textOfSetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            textOfSetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            
            flipContainerView.topAnchor.constraint(equalTo: textOfSetLabel.bottomAnchor, constant: SetDetailsConstants.flipContainerTopMargin),
            flipContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            flipContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            flipContainerView.heightAnchor.constraint(equalToConstant: SetDetailsConstants.flipContainerHeight),
            
            frontSideView.topAnchor.constraint(equalTo: flipContainerView.topAnchor),
            frontSideView.leadingAnchor.constraint(equalTo: flipContainerView.leadingAnchor),
            frontSideView.trailingAnchor.constraint(equalTo: flipContainerView.trailingAnchor),
            frontSideView.bottomAnchor.constraint(equalTo: flipContainerView.bottomAnchor),
            
            frontSideLabel.centerXAnchor.constraint(equalTo: frontSideView.centerXAnchor),
            frontSideLabel.centerYAnchor.constraint(equalTo: frontSideView.centerYAnchor),
            frontSideLabel.leadingAnchor.constraint(equalTo: frontSideView.leadingAnchor, constant: SetDetailsConstants.flipSideInset),
            frontSideLabel.trailingAnchor.constraint(equalTo: frontSideView.trailingAnchor, constant: -SetDetailsConstants.flipSideInset),
            
            backSideView.topAnchor.constraint(equalTo: flipContainerView.topAnchor),
            backSideView.leadingAnchor.constraint(equalTo: flipContainerView.leadingAnchor),
            backSideView.trailingAnchor.constraint(equalTo: flipContainerView.trailingAnchor),
            backSideView.bottomAnchor.constraint(equalTo: flipContainerView.bottomAnchor),
            
            backSideLabel.centerXAnchor.constraint(equalTo: backSideView.centerXAnchor),
            backSideLabel.centerYAnchor.constraint(equalTo: backSideView.centerYAnchor),
            backSideLabel.leadingAnchor.constraint(equalTo: backSideView.leadingAnchor, constant: SetDetailsConstants.flipSideInset),
            backSideLabel.trailingAnchor.constraint(equalTo: backSideView.trailingAnchor, constant: -SetDetailsConstants.flipSideInset),
            
            learnedButton.trailingAnchor.constraint(equalTo: backSideView.trailingAnchor, constant: -SetDetailsConstants.learnedButtonTrailing),
            learnedButton.bottomAnchor.constraint(equalTo: backSideView.bottomAnchor, constant: -SetDetailsConstants.learnedButtonBottom),
            learnedButton.heightAnchor.constraint(equalToConstant: SetDetailsConstants.learnedButtonHeight),
            
            prevButton.topAnchor.constraint(equalTo: flipContainerView.bottomAnchor, constant: SetDetailsConstants.arrowButtonsTopMargin),
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.prevButtonLeading),
            
            nextButton.topAnchor.constraint(equalTo: flipContainerView.bottomAnchor, constant: SetDetailsConstants.arrowButtonsTopMargin),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.nextButtonTrailing),
            
            deleteCardButton.topAnchor.constraint(equalTo: prevButton.bottomAnchor, constant: SetDetailsConstants.deleteCardButtonTopMargin),
            deleteCardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteCardButton.widthAnchor.constraint(equalToConstant: 184),
            deleteCardButton.heightAnchor.constraint(equalToConstant: SetDetailsConstants.deleteCardButtonHeight),
            
            cardList.topAnchor.constraint(equalTo: deleteCardButton.bottomAnchor, constant: SetDetailsConstants.cardListTopMargin),
            cardList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            cardList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            cardList.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -SetDetailsConstants.cardListBottomMargin),
            
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -SetDetailsConstants.bottomButtonsBottomMargin),
            changeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -SetDetailsConstants.bottomButtonsBottomMargin),
            studyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -SetDetailsConstants.bottomButtonsBottomMargin),
            
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            studyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            changeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            deleteButton.widthAnchor.constraint(equalToConstant: SetDetailsConstants.bottomButtonWidth),
            changeButton.widthAnchor.constraint(equalToConstant: SetDetailsConstants.bottomButtonWidth),
            studyButton.widthAnchor.constraint(equalToConstant: SetDetailsConstants.bottomButtonWidth),
            
            deleteButton.heightAnchor.constraint(equalToConstant: SetDetailsConstants.bottomButtonHeight),
            changeButton.heightAnchor.constraint(equalToConstant: SetDetailsConstants.bottomButtonHeight),
            studyButton.heightAnchor.constraint(equalToConstant: SetDetailsConstants.bottomButtonHeight)
        ])
    }
    
    // MARK: - Setup Progress Ring
    private func setupProgressRing() {
        let radius: CGFloat = SetDetailsConstants.progressCircleRadius
        let centerPoint = CGPoint(x: SetDetailsConstants.progressContainerSize / 2,
                                  y: SetDetailsConstants.progressContainerSize / 2)
        let circularPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
            clockwise: true
        )
        backgroundCircle.path = circularPath.cgPath
        backgroundCircle.strokeColor = ColorsLayoutConstants.linesColor.cgColor
        backgroundCircle.lineWidth = SetDetailsConstants.progressCircleLineWidth
        backgroundCircle.fillColor = UIColor.clear.cgColor
        backgroundCircle.lineCap = .round
        progressContainerView.layer.addSublayer(backgroundCircle)
        
        progressCircle.path = circularPath.cgPath
        progressCircle.strokeColor = ColorsLayoutConstants.basicColor.cgColor
        progressCircle.lineWidth = SetDetailsConstants.progressCircleLineWidth
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineCap = .round
        progressCircle.strokeEnd = 0
        progressContainerView.layer.addSublayer(progressCircle)
    }
    
    // MARK: - Update UI Methods
    private func updateFlashcardView(resetFlip: Bool = true) {
        guard !cards.isEmpty else {
            frontSideLabel.text = "No cards available"
            backSideLabel.text = ""
            learnedButton.setTitle("", for: .normal)
            return
        }
        let currentCard = cards[currentCardIndex]
        frontSideLabel.text = currentCard.question
        backSideLabel.text = currentCard.answer
        let checkbox = currentCard.isLearned ? "☑︎" : "☐"
        learnedButton.setTitle("\(checkbox)" + "learned_label".localized, for: .normal)
        
        if resetFlip {
            isFrontSide = true
            frontSideView.isHidden = false
            backSideView.isHidden = true
        }
    }
    
    private func updateProgressUI() {
        let total = cards.count
        let learnedCount = cards.filter { $0.isLearned }.count
        let progressPercent = total > 0 ? (learnedCount * 100 / total) : 0
        cardSet.progressOfSet = Int16(progressPercent)
        do {
            try context.save()
        } catch {
            os_log("Ошибка обновления прогрерфса сета: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
        progressCircle.strokeEnd = CGFloat(progressPercent) / 100.0
        progressLabel.text = "\(progressPercent)%"
    }
    
    // MARK: - Update Lock Button UI
    private func updateLockButtonUI() {
        let imageName = cardSet.isPublic ? "lock.open.fill" : "lock.fill"
        let image = UIImage(systemName: imageName)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        lockButton.setImage(image, for: .normal)
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .reveal
        transition.subtype = .fromLeft
        view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func shareTapped() {
        guard cardSet.isPublic else {
            let alert = UIAlertController(
                title: "private_set_title".localized,
                message: "private_set_message".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let setData: [String: Any] = [
            "n": cardSet.name ?? "",
            "d": cardSet.setDescription ?? "",
            "t": cardSet.textOfSet ?? "",
            "c": cards.map { ["q": $0.question ?? "", "a": $0.answer ?? ""] }
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: setData, options: []),
              let compressedData = jsonData.compressed() else { return }
        let base64String = compressedData.base64EncodedString(options: [])
        guard let encodedData = base64String.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        var urlComponents = URLComponents()
        urlComponents.scheme = "myapp"
        urlComponents.host = "createSet"
        urlComponents.queryItems = [URLQueryItem(name: "d", value: encodedData)]
        guard let url = urlComponents.url else { return }
        let activityVC = UIActivityViewController(activityItems: [url.absoluteString], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    @objc private func downloadTapped() {
        let context = self.context
        guard let setEntity = NSEntityDescription.entity(forEntityName: "CardSet", in: context) else { return }
        
        let newCardSet = CardSet(entity: setEntity, insertInto: context)
        
        newCardSet.id = UUID()
        
        if let currentUser = SessionManager.shared.currentUser {
            newCardSet.owner = currentUser
        }
        
        newCardSet.name = cardSet.name
        newCardSet.setDescription = cardSet.setDescription
        newCardSet.textOfSet = cardSet.textOfSet
        newCardSet.progressOfSet = 0
        
        for card in cards {
            guard let cardEntity = NSEntityDescription.entity(forEntityName: "Card", in: context) else { continue }
            let newCard = Card(entity: cardEntity, insertInto: context)
            newCard.id = UUID()
            newCard.question = card.question
            newCard.answer = card.answer
            newCard.isLearned = card.isLearned
            
            newCardSet.addToCards(newCard)
        }
        
        do {
            try context.save()
            let alert = UIAlertController(title: "Набор добавлен",
                                          message: "Новый набор успешно сохранен в базе данных.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } catch {
            os_log("Ошибка сохранения нового сета: %{public}@", log: logger, type: .error, error.localizedDescription)
            let alert = UIAlertController(title: "Ошибка",
                                          message: "Не удалось сохранить новый набор.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func flipCard() {
        guard !cards.isEmpty else { return }
        if isFrontSide {
            frontSideView.isHidden = true
            backSideView.isHidden = false
        } else {
            frontSideView.isHidden = false
            backSideView.isHidden = true
        }
        isFrontSide.toggle()
    }
    
    @objc private func prevCard() {
        guard !cards.isEmpty else { return }
        currentCardIndex = (currentCardIndex - 1 + cards.count) % cards.count
        updateFlashcardView()
    }
    
    @objc private func nextCard() {
        guard !cards.isEmpty else { return }
        currentCardIndex = (currentCardIndex + 1) % cards.count
        updateFlashcardView()
    }
    
    @objc private func learnedButtonTapped() {
        guard !cards.isEmpty else { return }
        let currentCard = cards[currentCardIndex]
        currentCard.isLearned.toggle()
        updateCurrentCardLearnedStatus(isLearned: currentCard.isLearned)
        let checkbox = currentCard.isLearned ? "☑︎" : "☐"
        learnedButton.setTitle("\(checkbox)" + "learned_label".localized, for: .normal)
        updateProgressUI()
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "del_set_message".localized,
            message: "sure_del_set_message".localized,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(
            title: "cancel_button_title".localized,
            style: .cancel,
            handler: nil
        )
        cancelAction.setValue(ColorsLayoutConstants.specialTextColor, forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        alert.addAction(UIAlertAction(
            title: "delete_label".localized,
            style: .destructive
        ) { [weak self] _ in
            guard let self = self,
                  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let ctx = appDelegate.persistentContainer.viewContext
            ctx.delete(self.cardSet)
            do {
                try ctx.save()
                NotificationCenter.default.post(
                    name: NSNotification.Name("SetDeletedNotification"),
                    object: nil
                )
                self.dismiss(animated: true)
            } catch {
                os_log(
                    "Error deleting set: %{public}@",
                    log: self.logger,
                    type: .error,
                    error.localizedDescription
                )
            }
        })
        
        present(alert, animated: true)
    }

    
    @objc private func changeCardTapped() {
            guard !cards.isEmpty else { return }
            let card = cards[currentCardIndex]
            let editVC = EditCardViewController(card: card)
            editVC.modalPresentationStyle = .pageSheet
            if let sheet = editVC.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customIdentifier = UISheetPresentationController.Detent.Identifier("custom")
                    let customDetent = UISheetPresentationController.Detent.custom(identifier: customIdentifier) { context in
                        return context.maximumDetentValue * 0.4
                    }
                    sheet.detents = [customDetent]
                } else {
                    editVC.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
                }
                sheet.prefersGrabberVisible = true
            }
            present(editVC, animated: true, completion: nil)
        }
    
    @objc private func editCardSetTapped() {
        let editVC = EditCardSetViewController(cardSet: cardSet)
        editVC.delegate = self
        editVC.modalPresentationStyle = .pageSheet
        if let sheet = editVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customIdentifier = UISheetPresentationController.Detent.Identifier("editCardSet")
                let customDetent = UISheetPresentationController.Detent.custom(identifier: customIdentifier) { context in
                    return context.maximumDetentValue * 0.4
                }
                sheet.detents = [customDetent]
            } else {
                editVC.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
            }
            sheet.prefersGrabberVisible = true
        }
        present(editVC, animated: true, completion: nil)
    }
    
    @objc private func studyTapped() {
        let studyVC = StudyViewController(cardSet: cardSet)
        studyVC.modalPresentationStyle = .pageSheet
        if let sheet = studyVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customIdentifier = UISheetPresentationController.Detent.Identifier("customStudy")
                let customDetent = UISheetPresentationController.Detent.custom(identifier: customIdentifier) { context in
                    return context.maximumDetentValue * 0.4
                }
                sheet.detents = [customDetent]
            } else {
                studyVC.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
            }
            sheet.prefersGrabberVisible = true
        }
        present(studyVC, animated: true, completion: nil)
    }

    @objc private func lockTapped() {
        cardSet.isPublic.toggle()
        
        do {
            try context.save()
        } catch {
            os_log("Ошибка сохранения изменения isPublic: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
        
        updateLockButtonUI()
    }
    
    // MARK: - Delete Current Card
    @objc private func deleteCurrentCard() {
        guard !cards.isEmpty else { return }

        let alert = UIAlertController(
            title: "del_card_message".localized,
            message: "sure_del_card_message".localized,
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(
            title: "cancel_button_title".localized,
            style: .cancel,
            handler: nil
        )
        cancelAction.setValue(ColorsLayoutConstants.specialTextColor, forKey: "titleTextColor")
        alert.addAction(cancelAction)

        alert.addAction(UIAlertAction(
            title: "delete_label".localized,
            style: .destructive
        ) { [weak self] _ in
            guard let self = self,
                  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let ctx = appDelegate.persistentContainer.viewContext

            let cardToDelete = self.cards[self.currentCardIndex]
            ctx.delete(cardToDelete)

            do {
                try ctx.save()
                try self.fetchedResultsController.performFetch()

                if self.cards.isEmpty {
                    ctx.delete(self.cardSet)
                    try ctx.save()
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SetDeletedNotification"),
                        object: nil
                    )
                    self.dismiss(animated: true)
                } else {
                    self.currentCardIndex = min(self.currentCardIndex, self.cards.count - 1)
                    self.cardList.reloadData()
                    self.updateFlashcardView()
                    self.updateProgressUI()
                }
            } catch {
                os_log(
                    "Error deleting card or set: %{public}@",
                    log: self.logger,
                    type: .error,
                    error.localizedDescription
                )
            }
        })

        present(alert, animated: true)
    }

    
    @objc private func updateLocalizedTexts() {
        learnedButton.setTitle("learned_label".localized, for: .normal)
        deleteCardButton.setTitle("deletecard_label".localized, for: .normal)
        deleteButton.setTitle("delete_label".localized, for: .normal)
        changeButton.setTitle("change_label".localized, for: .normal)
        studyButton.setTitle("study_label".localized, for: .normal)
    }
    
    // MARK: - Обновление данных в БД
    private func updateCurrentCardLearnedStatus(isLearned: Bool) {
        guard currentCardIndex < cards.count else { return }
        let currentCard = cards[currentCardIndex]
        currentCard.isLearned = isLearned
        do {
            try context.save()
            updateProgressUI()
        } catch {
            os_log("Ошибка сохранения карточки в БД: %{public}@", log: logger, type: .error, error.localizedDescription)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension SetDetailsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.cardList.reloadData()
            self.updateFlashcardView(resetFlip: false)
            self.updateProgressUI()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SetDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let card = cards[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "Q: \(card.question ?? "")\nA: \(card.answer ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        let editVC = EditCardViewController(card: card)
        editVC.modalPresentationStyle = .pageSheet
        if let sheet = editVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customIdentifier = UISheetPresentationController.Detent.Identifier("custom")
                let customDetent = UISheetPresentationController.Detent.custom(identifier: customIdentifier) { context in
                    return context.maximumDetentValue * 0.4
                }
                sheet.detents = [customDetent]
            } else {
                editVC.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
            }
            sheet.prefersGrabberVisible = true
        }
        present(editVC, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate - Deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card = cards[indexPath.row]
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let ctx = appDelegate.persistentContainer.viewContext
            ctx.delete(card)

            do {
                try ctx.save()
                try fetchedResultsController.performFetch()

                if cards.isEmpty {
                    ctx.delete(cardSet)
                    try ctx.save()
                    NotificationCenter.default.post(name: NSNotification.Name("SetDeletedNotification"), object: nil)
                    dismiss(animated: true)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    updateFlashcardView()
                    updateProgressUI()
                }
            } catch {
                os_log("Error deleting card or set: %{public}@", log: logger, type: .error, error.localizedDescription)
            }
        }
    }
}

// MARK: - EditCardViewControllerDelegate
extension SetDetailsViewController: EditCardViewControllerDelegate {
    func editCardViewController(_ controller: EditCardViewController, didUpdateCard card: Card) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let ctx = appDelegate.persistentContainer.viewContext
            do {
                try ctx.save()
                cardList.reloadData()
                if let index = cards.firstIndex(where: { $0 === card }) {
                    if currentCardIndex == index {
                        updateFlashcardView()
                    }
                }
            } catch {
                os_log("Error saving card: %{public}@", log: logger, type: .error, error.localizedDescription)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - EditCardSetViewControllerDelegate
extension SetDetailsViewController: EditCardSetViewControllerDelegate {
    func editCardSetViewController(_ controller: EditCardSetViewController, didUpdateCardSet cardSet: CardSet) {
        titleLabel.text = cardSet.name
        descriptionLabel.text = cardSet.setDescription
        controller.dismiss(animated: true, completion: nil)
    }
}
