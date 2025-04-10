import UIKit

// MARK: - Router
final class CalendarRouter: CalendarRoutingLogic, CalendarDataStore {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    var selectedDate: Date?
    
    // MARK: - Routing Logic
    func routeToDayDetail(at date: Date) {
    }
}
