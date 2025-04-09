import UIKit
import CoreData

// MARK: - Custom Collection View Cell
final class SelectionCell: UICollectionViewCell {
    static let reuseIdentifier = "SelectionCell"
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = ColorsLayoutConstants.specialTextColor.cgColor
        
        contentView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SelectionViewController
final class SelectionViewController: UIViewController {
    
    // MARK: - Свойства
    var cardSet: CardSet?
    private var cards: [Card] = []
    
    // Перемешанные данные
    private var shuffledQuestions: [Card] = []
    private var shuffledAnswers: [Card] = []
    
    // Для результатов
    private var totalInitialCards: Int = 0
    private var correctAnswers: Int = 0
    
    // Выбранные
    private var selectedQuestionCard: Card?
    private var selectedQuestionIndexPath: IndexPath?
    private var selectedAnswerIndexPath: IndexPath?
    
    // UI
    private let topBarView = UIView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let topSeparator = UIView()
    private let middleSeparator = UIView()
    private var questionsCollectionView: UICollectionView!
    private var answersCollectionView: UICollectionView!
    
    // MARK: - Инициализатор
    init(cardSet: CardSet) {
        self.cardSet = cardSet
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        
        if let set = cardSet,
           let cardObjects = set.cards?.allObjects as? [Card] {
            cards = cardObjects
            totalInitialCards = cards.count
            shuffledQuestions = cards.shuffled()
            shuffledAnswers   = cards.shuffled()
        }
        
        setupTopBar()
        setupCollectionViews()
        layoutUI()
    }
    
    // MARK: - Настройка верхней панели
    private func setupTopBar() {
        topBarView.backgroundColor = ColorsLayoutConstants.backgroundColor
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = ColorsLayoutConstants.basicColor
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        topBarView.addSubview(closeButton)
        
        titleLabel.text = "selection_label".localized
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(titleLabel)
        
        topSeparator.backgroundColor = ColorsLayoutConstants.linesColor
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topSeparator)
    }
    
    // MARK: - Настройка Collection Views
    private func setupCollectionViews() {
        let qLayout = UICollectionViewFlowLayout()
        qLayout.minimumLineSpacing = 10
        qLayout.minimumInteritemSpacing = 10
        qLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        questionsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: qLayout)
        questionsCollectionView.backgroundColor = .clear
        questionsCollectionView.dataSource = self
        questionsCollectionView.delegate = self
        questionsCollectionView.register(SelectionCell.self,
                                         forCellWithReuseIdentifier: SelectionCell.reuseIdentifier)
        questionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionsCollectionView)
        
        middleSeparator.backgroundColor = ColorsLayoutConstants.linesColor
        middleSeparator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(middleSeparator)
        
        let aLayout = UICollectionViewFlowLayout()
        aLayout.minimumLineSpacing = 10
        aLayout.minimumInteritemSpacing = 10
        aLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        answersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: aLayout)
        answersCollectionView.backgroundColor = .clear
        answersCollectionView.dataSource = self
        answersCollectionView.delegate = self
        answersCollectionView.register(SelectionCell.self,
                                       forCellWithReuseIdentifier: SelectionCell.reuseIdentifier)
        answersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(answersCollectionView)
    }
    
    // MARK: - Layout
    private func layoutUI() {
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: guide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 44),
            
            closeButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            
            topSeparator.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            questionsCollectionView.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 10),
            questionsCollectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            questionsCollectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            questionsCollectionView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.4),
            
            middleSeparator.topAnchor.constraint(equalTo: questionsCollectionView.bottomAnchor, constant: 10),
            middleSeparator.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            middleSeparator.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            middleSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            answersCollectionView.topAnchor.constraint(equalTo: middleSeparator.bottomAnchor, constant: 10),
            answersCollectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            answersCollectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            answersCollectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Действие закрыть
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension SelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cv == questionsCollectionView
            ? shuffledQuestions.count
            : shuffledAnswers.count
    }
    
    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = cv.dequeueReusableCell(
                withReuseIdentifier: SelectionCell.reuseIdentifier,
                for: indexPath) as? SelectionCell else {
            fatalError("Unable to dequeue SelectionCell")
        }
        
        let card = (cv == questionsCollectionView)
            ? shuffledQuestions[indexPath.item]
            : shuffledAnswers[indexPath.item]
        
        if cv == questionsCollectionView {
            cell.textLabel.text = card.question ?? "–"
            let isSel = selectedQuestionIndexPath == indexPath
            cell.contentView.backgroundColor = isSel
                ? ColorsLayoutConstants.basicColor.withAlphaComponent(0.5)
                : ColorsLayoutConstants.specialTextColor.withAlphaComponent(0.3)
        } else {
            cell.textLabel.text = card.answer ?? "–"
            let isSel = selectedAnswerIndexPath == indexPath
            cell.contentView.backgroundColor = isSel
                ? ColorsLayoutConstants.basicColor.withAlphaComponent(0.5)
                : ColorsLayoutConstants.specialTextColor.withAlphaComponent(0.3)
        }
        
        return cell
    }
    
    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cv == questionsCollectionView {
            if selectedQuestionIndexPath == indexPath {
                selectedQuestionIndexPath = nil
                selectedQuestionCard = nil
            } else {
                selectedQuestionIndexPath = indexPath
                selectedQuestionCard = shuffledQuestions[indexPath.item]
            }
            questionsCollectionView.reloadData()
            
        } else {
            if selectedAnswerIndexPath == indexPath {
                selectedAnswerIndexPath = nil
            } else {
                selectedAnswerIndexPath = indexPath
            }
            answersCollectionView.reloadData()
        }
        
        // проверяем пару
        if let qCard = selectedQuestionCard,
           let aIndex = selectedAnswerIndexPath {
            let aCard = shuffledAnswers[aIndex.item]
            if qCard.objectID == aCard.objectID {
                markAsCorrect(qIdx: selectedQuestionIndexPath!, aIdx: aIndex, card: aCard)

            } else {
                markAsIncorrect(qIdx: selectedQuestionIndexPath!, aIdx: aIndex)
            }
        }
    }
    
    func collectionView(_ cv: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 30
        let width = (view.frame.width - padding) / 3
        return CGSize(width: width, height: width)
    }
    
    // MARK: - Методы оценки
    private func markAsCorrect(qIdx: IndexPath, aIdx: IndexPath, card: Card) {
        card.isLearned = true
        highlight([qIdx, aIdx], color: ColorsLayoutConstants.correctanswerColor.withAlphaComponent(0.5))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.remove(card)
        }
    }
    
    private func markAsIncorrect(qIdx: IndexPath, aIdx: IndexPath) {
        highlight([qIdx, aIdx], color: ColorsLayoutConstants.basicColor.withAlphaComponent(0.5))
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.selectedQuestionCard = nil
            self.selectedQuestionIndexPath = nil
            self.selectedAnswerIndexPath = nil
            self.questionsCollectionView.reloadData()
            self.answersCollectionView.reloadData()
        }
    }
    
    private func highlight(_ idxs: [IndexPath], color: UIColor) {
        idxs.forEach { idx in
            let cv = (idx == selectedQuestionIndexPath)
                ? questionsCollectionView
                : answersCollectionView
            cv?.cellForItem(at: idx)?.contentView.backgroundColor = color
        }
    }
    
    private func remove(_ card: Card) {
        // теперь увеличиваем после удаления с экрана
        correctAnswers += 1
        
        shuffledQuestions.removeAll { $0.objectID == card.objectID }
        shuffledAnswers.removeAll   { $0.objectID == card.objectID }
        cards.removeAll             { $0.objectID == card.objectID }
        
        selectedQuestionCard = nil
        selectedQuestionIndexPath = nil
        selectedAnswerIndexPath = nil
        
        questionsCollectionView.reloadData()
        answersCollectionView.reloadData()
        
        if cards.isEmpty {
            showResults()
        }
    }
    
    private func showResults() {
        let pct = Int(Float(correctAnswers) / Float(totalInitialCards) * 100)
        let resultsVC = ResultsViewController.instantiate(
            leftScore: 0,
            rightScore: totalInitialCards,
            progress: pct
        ) { [weak self] in
            self?.dismiss(animated: true)
        }
        present(resultsVC, animated: true)
    }

}
