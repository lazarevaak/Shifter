import Foundation

// MARK: - Presenter
final class SetDetailsPresenter: SetDetailsPresentationLogic {

    // MARK: - Properties
    weak var viewController: SetDetailsDisplayLogic?

    // MARK: - Presentation Logic
    func presentFetchedCards(response: SetDetails.FetchCards.Response) {
        let descriptions = response.cards.map { card -> String in
            let question = card.question ?? ""
            let answer = card.answer ?? ""
            return "Q: \(question)\nA: \(answer)"
        }
        let viewModel = SetDetails.FetchCards.ViewModel(
            cardDescriptions: descriptions,
            progressPercent: 0
        )
        viewController?.displayFetchedCards(viewModel: viewModel)
    }

    func presentUpdatedProgress(response: SetDetails.UpdateProgress.Response) {
        let viewModel = SetDetails.UpdateProgress.ViewModel(
            progressText: "\(response.progressPercent)%"
        )
        viewController?.displayUpdatedProgress(viewModel: viewModel)
    }
}
