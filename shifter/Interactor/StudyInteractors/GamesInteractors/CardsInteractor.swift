import UIKit
import CoreData
import Compression

// MARK: - Model Flashcard
struct Flashcard {
    let question: String
    let answer: String
    var isLearned: Bool
}

// MARK: - Модели для передачи данных
enum CardsModels {
    struct FetchCardsRequest { }
    
    struct FetchCardsResponse {
        let flashcards: [Flashcard]
        let cardObjects: [Card]
    }
    
    struct FetchCardsViewModel {
        let currentFlashcard: FlashcardViewModel?
        let progressText: String
    }
    
    struct FlashcardViewModel {
        let question: String
        let answer: String
        let isLearned: Bool
    }
    
    struct UpdateLearnedStatusRequest {
        let isLearned: Bool
    }
    
    struct NextCardRequest { }
    
    struct NextCardResponse {
        let currentIndex: Int
    }
}

// MARK: - Protocols

// MARK: - Business Logic
protocol CardsBusinessLogic {
    func fetchCards(request: CardsModels.FetchCardsRequest)
    func updateLearnedStatus(request: CardsModels.UpdateLearnedStatusRequest)
    func moveToNextCard(request: CardsModels.NextCardRequest)
}

// MARK: - Display Logic
protocol CardsDisplayLogic: AnyObject {
    func displayFetchedCards(viewModel: CardsModels.FetchCardsViewModel)
    func displayNextCard(viewModel: CardsModels.FetchCardsViewModel)
}

// MARK: - Presentation Logic
protocol CardsPresentationLogic: AnyObject {
    func presentFetchedCards(response: CardsModels.FetchCardsResponse)
    func presentNextCard(response: CardsModels.NextCardResponse)
}

// MARK: - Interactor
final class CardsInteractor: CardsBusinessLogic {
    var presenter: CardsPresentationLogic?
    var cardSet: CardSet?
    
    private var flashcards: [Flashcard] = []
    private var cardObjects: [Card] = []
    
    var publicFlashcards: [Flashcard] {
        return flashcards
    }
    
    private(set) var correctCount: Int = 0
    
    private(set) var currentIndex: Int = 0
    
    var context: NSManagedObjectContext {
        if let ctx = cardSet?.managedObjectContext {
            return ctx
        } else {
            return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        }
    }
    
    init(cardSet: CardSet?) {
        self.cardSet = cardSet
        if let cardSet = cardSet,
           let cards = cardSet.cards?.allObjects as? [Card], !cards.isEmpty {
            self.cardObjects = cards
            self.flashcards = cards.map { card in
                Flashcard(
                    question: card.question ?? "",
                    answer: card.answer ?? "",
                    isLearned: card.isLearned
                )
            }
        } else {
            self.flashcards = []
            print("Ошибка: в CardSet нет карточек")
        }
    }
    
    func fetchCards(request: CardsModels.FetchCardsRequest) {
        let response = CardsModels.FetchCardsResponse(flashcards: flashcards, cardObjects: cardObjects)
        presenter?.presentFetchedCards(response: response)
    }
    
    func updateLearnedStatus(request: CardsModels.UpdateLearnedStatusRequest) {
        guard currentIndex < cardObjects.count else { return }
        let cardObject = cardObjects[currentIndex]
        
        if !cardObject.isLearned && request.isLearned {
            correctCount += 1
        } else if cardObject.isLearned && !request.isLearned {
            correctCount = max(0, correctCount - 1)
        }
        
        cardObject.isLearned = request.isLearned
        
        do {
            try context.save()
            updateProgressInDB()
        } catch {
            print("Ошибка сохранения карточки в БД: \(error)")
        }
    }

    
    func moveToNextCard(request: CardsModels.NextCardRequest) {
        if currentIndex < cardObjects.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = cardObjects.count
        }
        let response = CardsModels.NextCardResponse(currentIndex: currentIndex)
        presenter?.presentNextCard(response: response)
    }

    
    private func updateProgressInDB() {
        let total = cardObjects.count
        let learned = cardObjects.filter { $0.isLearned }.count
        let progressPercent = total > 0 ? (learned * 100 / total) : 0
        cardSet?.progressOfSet = Int16(progressPercent)
        
        do {
            try context.save()
        } catch {
            print("Ошибка обновления прогресса сета: \(error)")
        }
    }
    
    func setFlashcards(_ cards: [Flashcard]) {
        self.flashcards = cards
    }
}
