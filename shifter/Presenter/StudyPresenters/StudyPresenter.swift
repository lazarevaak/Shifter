import UIKit

// MARK: - Presenter
final class StudyPresenter: StudyPresentationLogic {

    // MARK: - Properties
    weak var viewController: StudyDisplayLogic?

    // MARK: - Presentation Logic
    func presentMenuItems(response: StudyModels.FetchMenuItemsResponse) {
        let viewModels = response.menuItems.map { item in
            StudyModels.MenuItemViewModel(
                id: item.id,
                iconName: item.iconName,
                title: item.title
            )
        }
        let viewModel = StudyModels.FetchMenuItemsViewModel(menuItems: viewModels)
        viewController?.displayMenuItems(viewModel: viewModel)
    }
}
