import UIKit
import CoreData

// MARK: - CalendarDayCell
final class CalendarDayCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarDayCell"

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: SizeLayoutConstants.instructionFontSize, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dayLabel)
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    func configure(with viewModel: CalendarDayViewModel) {
        if viewModel.dayNumber == 0 {
            dayLabel.text = ""
            contentView.backgroundColor = .clear
        } else {
            dayLabel.text = "\(viewModel.dayNumber)"
            if viewModel.isToday {
                dayLabel.textColor = ColorsLayoutConstants.buttonTextColor
                contentView.backgroundColor = ColorsLayoutConstants.basicColor
            } else {
                dayLabel.textColor = viewModel.isCurrentMonth ? .label : .secondaryLabel
                contentView.backgroundColor = viewModel.isWeekend
                    ? ColorsLayoutConstants.basicColor.withAlphaComponent(0.2)
                    : .clear
            }
        }
    }
}

// MARK: - ViewController
final class CalendarViewController: UIViewController, CalendarDisplayLogic {
    private var interactor: CalendarBusinessLogic?
    private var router: (CalendarRoutingLogic & CalendarDataStore)?
    private var days: [CalendarDayViewModel] = []
    private let context: NSManagedObjectContext

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: SizeLayoutConstants.textTitleSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let weekdayStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        return cv
    }()

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
        setupVIP()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        interactor?.fetchCalendar(request: .init(date: Date()))
    }

    private func setupVIP() {
        let interactor = CalendarInteractor(context: context)
        let presenter = CalendarPresenter()
        let router = CalendarRouter()

        interactor.presenter = presenter
        presenter.viewController = self

        self.interactor = interactor
        self.router = router
        router.viewController = self
    }

    private func setupViews() {
        view.addSubview(monthLabel)
        view.addSubview(weekdayStack)
        view.addSubview(collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)

        setupWeekdayStack()
        setupConstraints()
    }

    private func setupWeekdayStack() {
        let symbols = Calendar.current.shortWeekdaySymbols
        symbols.forEach { day in
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .secondaryLabel
            weekdayStack.addArrangedSubview(label)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            weekdayStack.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 8),
            weekdayStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekdayStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weekdayStack.heightAnchor.constraint(equalToConstant: 20),

            collectionView.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func displayCalendar(viewModel: CalendarModule.FetchDays.ViewModel) {
        monthLabel.text = viewModel.monthText
        days = viewModel.days
        collectionView.reloadData()
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let vm = days[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarDayCell.reuseIdentifier,
                for: indexPath
        ) as? CalendarDayCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: vm)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let totalSpacing: CGFloat = 2 * 6
        let width = (collectionView.frame.width - totalSpacing) / 7
        return CGSize(width: width, height: 32)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vm = days[indexPath.item]
        guard vm.dayNumber > 0,
              let firstOfMonth = Calendar.current.date(
                  from: Calendar.current.dateComponents([.year, .month], from: Date())
              ),
              let date = Calendar.current.date(
                  byAdding: .day,
                  value: vm.dayNumber - 1,
                  to: firstOfMonth
              )
        else { return }
        router?.routeToDayDetail(at: date)
    }
}
