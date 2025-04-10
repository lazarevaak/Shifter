import UIKit
import CoreData

// MARK: - Models
enum StudyModels {
    struct FetchMenuItemsRequest { }
    
    struct FetchMenuItemsResponse {
        let menuItems: [MenuItem]
    }
    
    struct FetchMenuItemsViewModel {
        let menuItems: [MenuItemViewModel]
    }
    
    struct MenuItem {
        let id: Int
        let iconName: String
        let title: String
    }
    
    struct MenuItemViewModel {
        let id: Int
        let iconName: String
        let title: String
    }
}

// MARK: - Protocols

// MARK: - Business Logic
protocol StudyBusinessLogic {
    func fetchMenuItems(request: StudyModels.FetchMenuItemsRequest)
}

// MARK: - Presentation Logic
protocol StudyPresentationLogic: AnyObject {
    func presentMenuItems(response: StudyModels.FetchMenuItemsResponse)
}

// MARK: - Display Logic
protocol StudyDisplayLogic: AnyObject {
    func displayMenuItems(viewModel: StudyModels.FetchMenuItemsViewModel)
}

// MARK: - Data Passing 
protocol SetDataReceivable {
    var setID: Int? { get set }
}

// MARK: - Interactor
final class StudyInteractor: StudyBusinessLogic {
    var presenter: StudyPresentationLogic?
    
    // MARK: Menu Items Source
    private let menuItems: [StudyModels.MenuItem] = [
        StudyModels.MenuItem(id: 1, iconName: "rectangle.stack", title: "cards_label".localized),
        StudyModels.MenuItem(id: 2, iconName: "arrow.clockwise.circle", title: "memorization_label".localized),
        StudyModels.MenuItem(id: 3, iconName: "doc.text", title: "test_label".localized),
        StudyModels.MenuItem(id: 4, iconName: "doc.on.doc", title: "selection_label".localized)
    ]
    
    // MARK: Fetch Menu Items
    func fetchMenuItems(request: StudyModels.FetchMenuItemsRequest) {
        let response = StudyModels.FetchMenuItemsResponse(menuItems: menuItems)
        presenter?.presentMenuItems(response: response)
    }
}
