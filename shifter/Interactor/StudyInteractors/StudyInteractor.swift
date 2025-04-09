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
protocol StudyBusinessLogic {
    func fetchMenuItems(request: StudyModels.FetchMenuItemsRequest)
}

protocol StudyPresentationLogic: AnyObject {
    func presentMenuItems(response: StudyModels.FetchMenuItemsResponse)
}

protocol StudyDisplayLogic: AnyObject {
    func displayMenuItems(viewModel: StudyModels.FetchMenuItemsViewModel)
}

protocol SetDataReceivable {
    var setID: Int? { get set }
}

// MARK: - Interactor
final class StudyInteractor: StudyBusinessLogic {
    var presenter: StudyPresentationLogic?
    
    private let menuItems: [StudyModels.MenuItem] = [
        StudyModels.MenuItem(id: 1, iconName: "rectangle.stack", title: "cards_label".localized),
        StudyModels.MenuItem(id: 2, iconName: "arrow.clockwise.circle", title: "memorization_label".localized),
        StudyModels.MenuItem(id: 3, iconName: "doc.text", title: "test_label".localized),
        StudyModels.MenuItem(id: 4, iconName: "doc.on.doc", title: "selection_label".localized)
    ]
    
    func fetchMenuItems(request: StudyModels.FetchMenuItemsRequest) {
        let response = StudyModels.FetchMenuItemsResponse(menuItems: menuItems)
        presenter?.presentMenuItems(response: response)
    }
}

