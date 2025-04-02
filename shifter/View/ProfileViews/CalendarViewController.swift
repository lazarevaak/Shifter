import UIKit
import CoreData

// MARK: - CalendarDayCell
final class CalendarDayCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarDayCell"
    
    private let dayLabel: UILabel = {
       let label = UILabel()
       label.textAlignment = .center
       label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
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
    
    func configure(with day: CalendarDay) {
        if day.dayNumber == 0 {
            dayLabel.text = ""
            contentView.backgroundColor = .clear
        } else {
            dayLabel.text = "\(day.dayNumber)"
            if day.isToday {
                dayLabel.textColor = .white
                contentView.backgroundColor = ColorsLayoutConstants.basicColor
            } else {
                dayLabel.textColor = day.isCurrentMonth ? .label : .secondaryLabel
                contentView.backgroundColor = day.isWeekend ? UIColor.systemRed.withAlphaComponent(0.2) : .clear
            }
        }
    }
}

// MARK: - CalendarView
final class CalendarViewController: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var days: [CalendarDay] = []
    private let context: NSManagedObjectContext
    
    private let monthLabel: UILabel = {
       let label = UILabel()
       label.textAlignment = .center
       label.font = UIFont.boldSystemFont(ofSize: 18)
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
    
    // MARK: - Инициализация
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(monthLabel)
        addSubview(weekdayStack)
        addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)
        
        setupWeekdayStack()
        setupConstraints()
        
        // Генерируем календарь для текущей даты
        generateDays(for: Date())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func setupWeekdayStack() {
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.textColor = .secondaryLabel
            weekdayStack.addArrangedSubview(label)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: topAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            weekdayStack.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 8),
            weekdayStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekdayStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            weekdayStack.heightAnchor.constraint(equalToConstant: 20),
            
            collectionView.topAnchor.constraint(equalTo: weekdayStack.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func generateDays(for date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstOfMonth = calendar.date(from: components) else { return }
        guard let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return }
        
        let dayCount = range.count
        
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        monthLabel.text = formatter.string(from: firstOfMonth)
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let weekdayOffset = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        let fetchRequest: NSFetchRequest<CalendarDay> = CalendarDay.fetchRequest()
        do {
            let oldDays = try context.fetch(fetchRequest)
            for d in oldDays {
                context.delete(d)
            }
            try context.save()
        } catch {
            print("Error cleaning old CalendarDay objects: \(error)")
        }
        
        days.removeAll()
        
        for _ in 0..<weekdayOffset {
            let dayEntity = CalendarDay(context: context)
            dayEntity.dayNumber = 0
            dayEntity.isCurrentMonth = false
            dayEntity.isToday = false
            dayEntity.isWeekend = false
            dayEntity.date = Date() 
            days.append(dayEntity)
        }
        
        let today = calendar.startOfDay(for: Date())
        
        for day in 1...dayCount {
            guard let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) else { continue }
            let isToday = calendar.isDate(dayDate, inSameDayAs: today)
            let weekday = calendar.component(.weekday, from: dayDate)
            let isWeekend = (weekday == 1 || weekday == 7)
            
            let dayEntity = CalendarDay(context: context)
            dayEntity.date = dayDate
            dayEntity.dayNumber = Int32(day)
            dayEntity.isToday = isToday
            dayEntity.isWeekend = isWeekend
            dayEntity.isCurrentMonth = true
            
            days.append(dayEntity)
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving CalendarDay objects: \(error)")
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseIdentifier, for: indexPath) as? CalendarDayCell else {
            return UICollectionViewCell()
        }
        let dayEntity = days[indexPath.item]
        cell.configure(with: dayEntity)
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 2 * 6 // 6 промежутков по 2
        let width = (collectionView.frame.width - totalSpacing) / 7
        return CGSize(width: width, height: 32)
    }
}
