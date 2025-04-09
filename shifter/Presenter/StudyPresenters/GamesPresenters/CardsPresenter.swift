import UIKit
import CoreData

// MARK: - Presenter
final class CardsPresenter: CardsPresentationLogic {

    // MARK: - Properties
    weak var viewController: CardsDisplayLogic?

    // MARK: - Presentation Logic
    func presentFetchedCards(response: CardsModels.FetchCardsResponse) {
        let flashcardVM: CardsModels.FlashcardViewModel? = response.flashcards.isEmpty ? nil : CardsModels.FlashcardViewModel(
            question: response.flashcards[0].question,
            answer: response.flashcards[0].answer,
            isLearned: response.flashcards[0].isLearned
        )
        let progressText = "1/\(response.flashcards.count)"
        let viewModel = CardsModels.FetchCardsViewModel(
            currentFlashcard: flashcardVM,
            progressText: progressText
        )
        viewController?.displayFetchedCards(viewModel: viewModel)
    }

    func presentNextCard(response: CardsModels.NextCardResponse) {
        let totalCards = (viewController as? CardsViewController)?.totalCards ?? 0
        let currentProgress = response.currentIndex > totalCards ? totalCards : response.currentIndex
        let progressText = "\(currentProgress)/\(totalCards)"
        let flashcardVM: CardsModels.FlashcardViewModel? = nil
        let viewModel = CardsModels.FetchCardsViewModel(
            currentFlashcard: flashcardVM,
            progressText: progressText
        )
        viewController?.displayNextCard(viewModel: viewModel)
    }
}

