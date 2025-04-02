import UIKit

protocol SetDataReceivable {
    var setID: Int? { get set }
}

final class StudyViewController: UIViewController {
    
    private let menuItems: [(id: Int, iconName: String, title: String)] = [
        (id: 1, iconName: "rectangle.stack", title: "Карточки"),
        (id: 2, iconName: "arrow.clockwise.circle", title: "Заучивание"),
        (id: 3, iconName: "doc.text", title: "Тест"),
        (id: 4, iconName: "doc.on.doc", title: "Подбор")
    ]
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = UIColor.clear
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "YourDarkColor") ?? UIColor.systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StudyCell")
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension StudyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = menuItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudyCell", for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        if let image = UIImage(systemName: item.iconName)?.withTintColor(.red, renderingMode: .alwaysOriginal) {
            config.image = image
            config.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        }
        config.text = item.title
        config.textProperties.color = .gray
        
        cell.contentConfiguration = config
        cell.backgroundColor = UIColor(named: "YourDarkColor") ?? .systemBackground
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menuItems[indexPath.row]
        var vc: UIViewController?
        
        switch item.title {
        case "Карточки":
            vc = CardsViewController()
        case "Заучивание":
            vc = MemorizationViewController()
        case "Тест":
            vc = TestViewController()
        case "Подбор":
            vc = SelectionViewController()
        default:
            break
        }
        
        if var setReceiver = vc as? SetDataReceivable {
            setReceiver.setID = item.id
        }
        
        if let viewController = vc {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true, completion: nil)
        }
    }
}
