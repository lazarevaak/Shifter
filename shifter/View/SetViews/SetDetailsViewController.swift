import UIKit
import CoreData
import Compression 

extension Data {
    func compressed() -> Data? {
        let bufferSize = 64 * 1024
        var sourceBuffer = [UInt8](self)
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { destinationBuffer.deallocate() }
        let compressedSize = compression_encode_buffer(destinationBuffer,
                                                         bufferSize,
                                                         &sourceBuffer,
                                                         self.count,
                                                         nil as UnsafeMutableRawPointer?,
                                                         COMPRESSION_ZLIB)
        guard compressedSize != 0 else { return nil }
        return Data(bytes: destinationBuffer, count: compressedSize)
    }
}

// MARK: - Константы для SetDetailsViewController
enum SetDetailsConstants {
    static let topSafeAreaMargin: CGFloat = 10
    static let backButtonLeading: CGFloat = 16
    static let titleUnderlineTop: CGFloat = 8
    static let contentHorizontalInset: CGFloat = 20
    static let progressContainerSize: CGFloat = 120
    static let progressContainerTopMargin: CGFloat = 20
    static let descriptionTopMargin: CGFloat = 20
    static let textOfSetTopMargin: CGFloat = 10
    static let flipContainerTopMargin: CGFloat = 20
    static let flipContainerHeight: CGFloat = 180
    static let flipContainerCornerRadius: CGFloat = 10
    static let flipContainerBorderWidth: CGFloat = 1
    static let flipSideInset: CGFloat = 20
    static let arrowButtonsTopMargin: CGFloat = 10
    static let prevButtonLeading: CGFloat = 40
    static let nextButtonTrailing: CGFloat = 40
    static let deleteCardButtonTopMargin: CGFloat = 10
    static let deleteCardButtonWidth: CGFloat = 120
    static let deleteCardButtonHeight: CGFloat = 40
    static let cardListTopMargin: CGFloat = 20
    static let cardListBottomMargin: CGFloat = 20

    static let bottomButtonsBottomMargin: CGFloat = 20
    static let bottomButtonsHorizontalSpacing: CGFloat = 10
    static let bottomButtonWidth: CGFloat = 100
    static let bottomButtonHeight: CGFloat = 40

    static let learnedButtonTrailing: CGFloat = 10
    static let learnedButtonBottom: CGFloat = 10
    static let learnedButtonHeight: CGFloat = 30

    static let progressCircleRadius: CGFloat = 50
    static let progressCircleLineWidth: CGFloat = 10

    static let underlineHeight: CGFloat = 1

    static let titleFontSize: CGFloat = 24
    static let progressFontSize: CGFloat = 18
    static let descriptionFontSize: CGFloat = 16
    static let cardFontSize: CGFloat = 16
    static let arrowButtonFontSize: CGFloat = 24
}

class SetDetailsViewController: UIViewController {

    // MARK: - Свойства

    private let cardSet: CardSet
    private var cards: [Card] = []
    private var currentCardIndex = 0
    private var isFrontSide = true

    // MARK: - UI Элементы

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.left")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set Details"
        label.font = UIFont.boldSystemFont(ofSize: SetDetailsConstants.titleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = ColorsLayoutConstants.additionalColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Круговой прогресс
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

    // Описание и текст набора (ниже прогресса)
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
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

    // MARK: - Флеш-карта (flip-контейнер)
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
        v.backgroundColor = ColorsLayoutConstants.buttonTextbackgroundColor
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
        v.backgroundColor = ColorsLayoutConstants.buttonTextbackgroundColor
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

    // Кнопка Learned (с чекбоксом), в правом нижнем углу
    private let learnedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("☐ Learned", for: .normal)
        button.tintColor = ColorsLayoutConstants.basicColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("◀︎", for: .normal)
        button.tintColor = .systemGray4
        button.titleLabel?.font = UIFont.systemFont(ofSize: SetDetailsConstants.arrowButtonFontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("▶︎", for: .normal)
        button.tintColor = .systemGray4
        button.titleLabel?.font = UIFont.systemFont(ofSize: SetDetailsConstants.arrowButtonFontSize)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let deleteCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Card", for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextbackgroundColor, for: .normal)
        button.backgroundColor = .red
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

    // Кнопки Delete Set, Change Set и Study
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextbackgroundColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change", for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextbackgroundColor, for: .normal)
        button.backgroundColor = ColorsLayoutConstants.specialTextColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let studyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Study", for: .normal)
        button.setTitleColor(ColorsLayoutConstants.buttonTextbackgroundColor, for: .normal)
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
        view.backgroundColor = ColorsLayoutConstants.buttonTextbackgroundColor

        // Настройка делегатов, добавление target для кнопок и пр.
        cardList.delegate = self
        cardList.dataSource = self

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevCard), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextCard), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(changeTapped), for: .touchUpInside)
        studyButton.addTarget(self, action: #selector(studyTapped), for: .touchUpInside)
        learnedButton.addTarget(self, action: #selector(learnedButtonTapped), for: .touchUpInside)
        deleteCardButton.addTarget(self, action: #selector(deleteCurrentCard), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        flipContainerView.addGestureRecognizer(tapGesture)

        setupLayout()
        setupProgressRing()

        titleLabel.text = cardSet.name ?? "Untitled"
        descriptionLabel.text = cardSet.setDescription ?? ""
        textOfSetLabel.text = cardSet.textOfSet ?? ""

        if let cardObjects = cardSet.cards?.allObjects as? [Card] {
            cards = cardObjects
        }
        updateFlashcardView()
        updateProgressUI()
    }

    // MARK: - Размещение элементов
    private func setupLayout() {
        // Верхняя панель
        view.addSubview(backButton)
        view.addSubview(shareButton)
        view.addSubview(titleLabel)
        view.addSubview(titleUnderline)

        // Прогресс
        view.addSubview(progressContainerView)
        progressContainerView.addSubview(progressLabel)

        // Описание
        view.addSubview(descriptionLabel)
        view.addSubview(textOfSetLabel)

        // Флеш-карта
        view.addSubview(flipContainerView)
        flipContainerView.addSubview(frontSideView)
        flipContainerView.addSubview(backSideView)
        frontSideView.addSubview(frontSideLabel)
        backSideView.addSubview(backSideLabel)
        backSideView.addSubview(learnedButton)

        // Кнопки стрелок
        view.addSubview(prevButton)
        view.addSubview(nextButton)

        // Кнопка удаления текущей карточки
        view.addSubview(deleteCardButton)

        // Таблица
        view.addSubview(cardList)

        // Кнопки Delete Set, Change Set и Study
        view.addSubview(deleteButton)
        view.addSubview(changeButton)
        view.addSubview(studyButton)

        NSLayoutConstraint.activate([
            // Кнопка «Назад» в левом верхнем углу
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SetDetailsConstants.topSafeAreaMargin),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.backButtonLeading),
            
            // Кнопка «Поделиться» располагается справа на экране и поднята выше (верхний отступ 5)
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.backButtonLeading),
            
            // Заголовок по центру верхней панели
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SetDetailsConstants.topSafeAreaMargin),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Линия под заголовком
            titleUnderline.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: SetDetailsConstants.titleUnderlineTop),
            titleUnderline.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            titleUnderline.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            titleUnderline.heightAnchor.constraint(equalToConstant: SetDetailsConstants.underlineHeight),

            // Прогресс
            progressContainerView.topAnchor.constraint(equalTo: titleUnderline.bottomAnchor, constant: SetDetailsConstants.progressContainerTopMargin),
            progressContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressContainerView.widthAnchor.constraint(equalToConstant: SetDetailsConstants.progressContainerSize),
            progressContainerView.heightAnchor.constraint(equalToConstant: SetDetailsConstants.progressContainerSize),

            progressLabel.centerXAnchor.constraint(equalTo: progressContainerView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: progressContainerView.centerYAnchor),

            // Описание
            descriptionLabel.topAnchor.constraint(equalTo: progressContainerView.bottomAnchor, constant: SetDetailsConstants.descriptionTopMargin),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),

            textOfSetLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: SetDetailsConstants.textOfSetTopMargin),
            textOfSetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            textOfSetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),

            // Флеш-карта
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

            // Кнопки стрелок (◀︎ и ▶︎)
            prevButton.topAnchor.constraint(equalTo: flipContainerView.bottomAnchor, constant: SetDetailsConstants.arrowButtonsTopMargin),
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.prevButtonLeading),

            nextButton.topAnchor.constraint(equalTo: flipContainerView.bottomAnchor, constant: SetDetailsConstants.arrowButtonsTopMargin),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.nextButtonTrailing),

            // Кнопка удаления карточки
            deleteCardButton.topAnchor.constraint(equalTo: prevButton.bottomAnchor, constant: SetDetailsConstants.deleteCardButtonTopMargin),
            deleteCardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteCardButton.widthAnchor.constraint(equalToConstant: SetDetailsConstants.deleteCardButtonWidth),
            deleteCardButton.heightAnchor.constraint(equalToConstant: SetDetailsConstants.deleteCardButtonHeight),

            // Таблица
            cardList.topAnchor.constraint(equalTo: deleteCardButton.bottomAnchor, constant: SetDetailsConstants.cardListTopMargin),
            cardList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SetDetailsConstants.contentHorizontalInset),
            cardList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SetDetailsConstants.contentHorizontalInset),
            cardList.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -SetDetailsConstants.cardListBottomMargin),

            // Кнопки Delete Set, Change Set и Study: располагаем их горизонтально
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

    // MARK: - Настройка кругового прогресса
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
        backgroundCircle.strokeColor = ColorsLayoutConstants.additionalColor.cgColor
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

    // MARK: - Обновление UI прогресса
    private func updateProgressUI() {
        let total = cards.count
        let learnedCount = cards.filter { $0.isLearned }.count
        let progressPercent = total > 0 ? (learnedCount * 100 / total) : 0
        cardSet.progressOfSet = Int16(progressPercent)

        progressCircle.strokeEnd = CGFloat(progressPercent) / 100.0
        progressLabel.text = "\(progressPercent)%"
    }

    // MARK: - Обновление флеш-карточки
    private func updateFlashcardView() {
        guard !cards.isEmpty else {
            frontSideLabel.text = "No cards available"
            backSideLabel.text = ""
            learnedButton.setTitle("", for: .normal)
            return
        }
        isFrontSide = true
        frontSideView.isHidden = false
        backSideView.isHidden = true

        let currentCard = cards[currentCardIndex]
        frontSideLabel.text = currentCard.question
        backSideLabel.text = currentCard.answer

        let checkbox = currentCard.isLearned ? "☑︎" : "☐"
        learnedButton.setTitle("\(checkbox) Learned", for: .normal)
    }

    // MARK: - Действия

    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func shareTapped() {
        let setData: [String: Any] = [
            "n": cardSet.name ?? "",
            "d": cardSet.setDescription ?? "",
            "t": cardSet.textOfSet ?? "",
            "c": cards.map { ["q": $0.question ?? "", "a": $0.answer ?? ""] }
        ]
        
        // Сериализуем данные в минимизированный JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: setData, options: []) else { return }
        
        guard let compressedData = jsonData.compressed() else { return }
        
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

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            do {
                try context.save()
                updateProgressUI()
                let checkbox = currentCard.isLearned ? "☑︎" : "☐"
                learnedButton.setTitle("\(checkbox) Learned", for: .normal)
            } catch {
                print("Ошибка сохранения карточки: \(error)")
            }
        }
    }

    @objc private func deleteTapped() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(cardSet)

        do {
            try context.save()
            print("Set deleted!")
            // Публикуем уведомление о том, что сет удалён
            NotificationCenter.default.post(name: NSNotification.Name("SetDeletedNotification"), object: nil)
            dismiss(animated: true, completion: nil)
        } catch {
            print("Error deleting set: \(error)")
        }
    }

    @objc private func changeTapped() {
        guard !cards.isEmpty else { return }
        let card = cards[currentCardIndex]
        let editVC = EditCardViewController(card: card)
        editVC.delegate = self
        editVC.modalPresentationStyle = .pageSheet
        if let sheet = editVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customIdentifier = UISheetPresentationController.Detent.Identifier("custom")
                sheet.detents = [.custom(identifier: customIdentifier, resolver: { context in
                    return context.maximumDetentValue * 0.4
                })]
            } else {
                editVC.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
        }
        present(editVC, animated: true, completion: nil)
    }

    @objc private func studyTapped() {
        // Вместо (или вместе с) фильтрации карточек
        // можно просто открыть новый экран:
        let studyVC = StudyViewController()
        
        // Если нужно передавать какие-то данные о карточках,
        // вы можете добавить свойство в StudyViewController, например:
        // studyVC.cardsToStudy = cards.filter { !$0.isLearned }
        
        // Настройка формы отображения (лист)
        studyVC.modalPresentationStyle = .pageSheet
        if let sheet = studyVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                let customIdentifier = UISheetPresentationController.Detent.Identifier("customStudy")
                sheet.detents = [.custom(identifier: customIdentifier, resolver: { context in
                    return context.maximumDetentValue * 0.4
                })]
            } else {
                // Для iOS < 16 можно ограничиться .medium() или .large()
                studyVC.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
        }
        present(studyVC, animated: true, completion: nil)
    }


    @objc private func deleteCurrentCard() {
        guard !cards.isEmpty else { return }
        let currentCard = cards[currentCardIndex]
        let alert = UIAlertController(title: "Delete Card", message: "Are you sure you want to delete this card?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self, let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            context.delete(currentCard)
            do {
                try context.save()
                self.cards.remove(at: self.currentCardIndex)
                if self.currentCardIndex >= self.cards.count {
                    self.currentCardIndex = max(0, self.cards.count - 1)
                }
                self.cardList.reloadData()
                self.updateFlashcardView()
                self.updateProgressUI()
            } catch {
                print("Error deleting card: \(error)")
            }
        }))
        present(alert, animated: true)
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
    
    // Вместо UIAlertController для редактирования карточки, презентуем кастомный экран (EditCardViewController)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        let editVC = EditCardViewController(card: card)
        editVC.delegate = self
        editVC.modalPresentationStyle = .pageSheet
        present(editVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card = cards[indexPath.row]
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let context = appDelegate.persistentContainer.viewContext
                context.delete(card)
                do {
                    try context.save()
                    cards.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.updateFlashcardView()
                    self.updateProgressUI()
                } catch {
                    print("Error deleting card: \(error)")
                }
            }
        }
    }
}

// MARK: - Реализация делегата EditCardViewControllerDelegate
extension SetDetailsViewController: EditCardViewControllerDelegate {
    func editCardViewController(_ controller: EditCardViewController, didUpdateCard card: Card) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            do {
                try context.save()
                cardList.reloadData()
                if let index = cards.firstIndex(where: { $0 === card }) {
                    if currentCardIndex == index {
                        updateFlashcardView()
                    }
                }
            } catch {
                print("Error saving card: \(error)")
            }
        }
    }
}
