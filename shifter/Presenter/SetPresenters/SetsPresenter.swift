import Foundation

// MARK: - Presenter
final class SetsPresenter: SetsPresentationLogic {

    // MARK: - Properties
    weak var viewController: SetsDisplayLogic?

    // MARK: - Presentation Logic
    func presentFetchedSets(response: SetsModels.FetchSetsResponse) {
        let viewModels = response.sets.map { set in
            SetsModels.CardSetViewModel(
                name: set.name ?? "untitled".localized,
                progressOfSet: set.progressOfSet,
                id: set.objectID
            )
        }
        let viewModel = SetsModels.FetchSetsViewModel(displayedSets: viewModels)
        viewController?.displayFetchedSets(viewModel: viewModel)
    }

    func presentSearchedSets(response: SetsModels.SearchResponse) {
        let viewModels = response.sets.map { set in
            SetsModels.CardSetViewModel(
                name: set.name ?? "untitled".localized,
                progressOfSet: set.progressOfSet,
                id: set.objectID
            )
        }
        let viewModel = SetsModels.FetchSetsViewModel(displayedSets: viewModels)
        viewController?.displayFetchedSets(viewModel: viewModel)
    }

    func presentSortedSets(sets: [CardSet]) {
        let viewModels = sets.map { set in
            SetsModels.CardSetViewModel(
                name: set.name ?? "untitled".localized,
                progressOfSet: set.progressOfSet,
                id: set.objectID
            )
        }
        let viewModel = SetsModels.FetchSetsViewModel(displayedSets: viewModels)
        viewController?.displayFetchedSets(viewModel: viewModel)
    }

    func presentDeletedSet() {
    }
}
