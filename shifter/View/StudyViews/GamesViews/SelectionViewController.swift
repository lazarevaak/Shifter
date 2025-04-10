import UIKit

final class SelectionViewController: UIViewController {
    var interactor: SelectionBusinessLogic?
    var router: SelectionRoutingLogic?

    private var questionTexts: [String] = []
    private var answerTexts: [String] = []
    private var selectedQuestionIndex: Int?
    private var selectedAnswerIndex: Int?

    private let topBarView = UIView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let topSeparator = UIView()
    private let midSeparator = UIView()

    private lazy var questionsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(SelectionCell.self,
                    forCellWithReuseIdentifier: SelectionCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private lazy var answersCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(SelectionCell.self,
                    forCellWithReuseIdentifier: SelectionCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: — Init & VIP setup
    init(cardSet: CardSet) {
        super.init(nibName: nil, bundle: nil)
        setupVIP(with: cardSet)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func setupVIP(with cardSet: CardSet) {
        let interactor = SelectionInteractor(cardSet: cardSet)
        let presenter = SelectionPresenter()
        let router = SelectionRouter()

        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }

    // MARK: — Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        setupTopBar()
        setupLayout()
        interactor?.load(request: .init())
    }

    private func setupTopBar() {
        topBarView.backgroundColor = ColorsLayoutConstants.backgroundColor
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = ColorsLayoutConstants.basicColor
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(closeButton)

        titleLabel.text = "selection_label".localized
        titleLabel.font = .boldSystemFont(ofSize: SizeLayoutConstants.testTextSize)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(titleLabel)

        topSeparator.backgroundColor = ColorsLayoutConstants.linesColor
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topSeparator)

        midSeparator.backgroundColor = ColorsLayoutConstants.linesColor
        midSeparator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(midSeparator)
    }

    private func setupLayout() {
        let safe = view.safeAreaLayoutGuide
        view.addSubview(questionsCollection)
        view.addSubview(answersCollection)
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: safe.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: SizeLayoutConstants.editHeightAnchorSize),

            closeButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: GamesConstants.buttonSize),
            closeButton.heightAnchor.constraint(equalToConstant: GamesConstants.buttonSize),

            titleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),

            topSeparator.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 1),

            questionsCollection.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: GamesConstants.collectionSize),
            questionsCollection.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            questionsCollection.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            questionsCollection.heightAnchor.constraint(equalTo: safe.heightAnchor, multiplier: 0.4),

            midSeparator.topAnchor.constraint(equalTo: questionsCollection.bottomAnchor, constant: GamesConstants.collectionSize),
            midSeparator.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: GamesConstants.separatorSize),
            midSeparator.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -GamesConstants.separatorSize),
            midSeparator.heightAnchor.constraint(equalToConstant: 1),

            answersCollection.topAnchor.constraint(equalTo: midSeparator.bottomAnchor, constant: GamesConstants.collectionSize),
            answersCollection.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            answersCollection.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            answersCollection.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -GamesConstants.collectionSize)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: — Display Logic
extension SelectionViewController: SelectionDisplayLogic {
    func displayLoad(viewModel: Selection.Load.ViewModel) {
        questionTexts = viewModel.questionTexts
        answerTexts = viewModel.answerTexts
        questionsCollection.reloadData()
        answersCollection.reloadData()
    }

    func displayEvaluation(viewModel: Selection.Evaluate.ViewModel) {
        let qIdx = viewModel.questionIndex
        let aIdx = viewModel.answerIndex
        let color = viewModel.isCorrect
            ? ColorsLayoutConstants.correctanswerColor.withAlphaComponent(0.5)
            : ColorsLayoutConstants.basicColor.withAlphaComponent(0.5)

        questionsCollection.cellForItem(at: IndexPath(item: qIdx, section: 0))?
            .contentView.backgroundColor = color
        answersCollection.cellForItem(at: IndexPath(item: aIdx, section: 0))?
            .contentView.backgroundColor = color

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if viewModel.isCorrect {
                self.questionTexts = viewModel.questionTexts
                self.answerTexts = viewModel.answerTexts
                self.selectedQuestionIndex = nil
                self.selectedAnswerIndex = nil
                self.questionsCollection.reloadData()
                self.answersCollection.reloadData()
                if viewModel.questionTexts.isEmpty {
                    self.router?.routeToResults(
                        correctCount: viewModel.correctCount,
                        total: viewModel.total
                    )
                }
            } else {
                self.selectedQuestionIndex = nil
                self.selectedAnswerIndex = nil
                self.questionsCollection.reloadData()
                self.answersCollection.reloadData()
            }
        }
    }
}

// MARK: — Collection DataSource & Delegate
extension SelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (cv == questionsCollection) ? questionTexts.count : answerTexts.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let txt = (cv == questionsCollection) ? questionTexts[indexPath.item] : answerTexts[indexPath.item]
        let cell = cv.dequeueReusableCell(withReuseIdentifier: SelectionCell.reuseIdentifier,
                                          for: indexPath) as! SelectionCell
        cell.textLabel.text = txt
        let isSel = (cv == questionsCollection ? selectedQuestionIndex == indexPath.item :
                     selectedAnswerIndex == indexPath.item)
        cell.contentView.backgroundColor = isSel
            ? ColorsLayoutConstants.basicColor.withAlphaComponent(0.5)
            : ColorsLayoutConstants.specialTextColor.withAlphaComponent(0.3)
        return cell
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cv == questionsCollection {
            selectedQuestionIndex = (selectedQuestionIndex == indexPath.item) ? nil : indexPath.item
        } else {
            selectedAnswerIndex = (selectedAnswerIndex == indexPath.item) ? nil : indexPath.item
        }
        cv.reloadData()
        if let q = selectedQuestionIndex, let a = selectedAnswerIndex {
            interactor?.evaluate(request: .init(questionIndex: q, answerIndex: a))
        }
    }

    func collectionView(_ cv: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 30
        let width = (view.frame.width - padding) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - SelectionCell
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
        contentView.backgroundColor = ColorsLayoutConstants.specialTextColor.withAlphaComponent(0.3)
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
