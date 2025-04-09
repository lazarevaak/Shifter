import UIKit

// MARK: - Presenter
final class EditCardPresenter: EditCardPresentationLogic {

    // MARK: - Properties
    weak var viewController: EditCardDisplayLogic?

    // MARK: - Presentation Logic
    func presentUpdatedCard(response: EditCard.UpdateCard.Response) {
        let viewModel = EditCard.UpdateCard.ViewModel(card: response.card)
        viewController?.displayUpdatedCard(viewModel: viewModel)
    }
}

