import Foundation
import CoreData

struct MultipleChoiceCard {
    let question: String
    let correctAnswer: String
    var isLearned: Bool
    var options: [String] = []
}

struct MemorizationCardViewModel {
    let question: String
    let options: [String]
    let correctAnswer: String
}

enum Memorization {
    enum LoadCards {
        struct Request { }
        struct ViewModel {
            let displayCards: [MemorizationCardViewModel]
            let currentIndex: Int
            let totalCount: Int
            let progress: Float
        }
    }
    
    enum OptionSelected {
        struct Request {
            let selectedOption: String
        }
    }
}

protocol MemorizationBusinessLogic {
    func loadCards(request: Memorization.LoadCards.Request)
    func selectOption(request: Memorization.OptionSelected.Request)
}

// MARK: - Routing Protocol
protocol MemorizationRoutingLogic {
    func routeToResults(correctAnswers: Int, total: Int)
}

// MARK: - Presentation Logic
protocol MemorizationPresentationLogic {
    func presentCards(response: Memorization.LoadCards.ViewModel)
    func presentOptionResult(isCorrect: Bool, viewModel: Memorization.LoadCards.ViewModel)
    func presentError(message: String)
    func presentFinish(correctAnswers: Int, total: Int)
}

final class MemorizationInteractor: MemorizationBusinessLogic {
    
    var presenter: MemorizationPresentationLogic?
    var cardSet: CardSet?
    
    private var cards: [MultipleChoiceCard] = []
    private var correctAnswersCount: Int = 0
    private var originalCardsCount: Int = 0
    
    func loadCards(request: Memorization.LoadCards.Request) {
        guard let cardSet = cardSet,
              let cardObjects = cardSet.cards?.allObjects as? [Card],
              !cardObjects.isEmpty else {
            presenter?.presentError(message: "Набор карточек не найден.")
            return
        }
        
        self.cards = cardObjects.map { card in
            MultipleChoiceCard(
                question: card.question ?? "",
                correctAnswer: card.answer ?? "",
                isLearned: card.isLearned
            )
        }
        originalCardsCount = cards.count
        correctAnswersCount = 0
        
        sendCurrentCardToPresenter()
    }
    
    func selectOption(request: Memorization.OptionSelected.Request) {
        guard !cards.isEmpty else { return }
        let currentCard = cards[0]
        
        let isCorrect = (request.selectedOption == currentCard.correctAnswer)
        if isCorrect {
            correctAnswersCount += 1
            updateCardLearningStatus(for: currentCard, learned: true)
            cards.remove(at: 0)
        } else {
            updateCardLearningStatus(for: currentCard, learned: false)
            let card = cards.remove(at: 0)
            cards.append(card)
        }
        
        saveContext()
        
        if cards.isEmpty {
            presenter?.presentFinish(correctAnswers: correctAnswersCount, total: originalCardsCount)
            return
        }
        
        sendCurrentCardToPresenter(withAnswerCorrectness: isCorrect)
    }
    
    private func sendCurrentCardToPresenter(withAnswerCorrectness isCorrect: Bool? = nil) {
        let currentCard = cards[0]
        let options = optionsForCard(currentCard)
        let cardVM = MemorizationCardViewModel(question: currentCard.question,
                                               options: options,
                                               correctAnswer: currentCard.correctAnswer)
        let progress = Float(correctAnswersCount + 1) / Float(originalCardsCount)
        let viewModel = Memorization.LoadCards.ViewModel(displayCards: [cardVM],
                                                         currentIndex: correctAnswersCount + 1,
                                                         totalCount: originalCardsCount,
                                                         progress: progress)
        if let isCorrect = isCorrect {
            presenter?.presentOptionResult(isCorrect: isCorrect, viewModel: viewModel)
        } else {
            presenter?.presentCards(response: viewModel)
        }
    }
    
    private func optionsForCard(_ card: MultipleChoiceCard) -> [String] {
        let totalOptionsCount = 4
        var distractors = cards.filter { $0.correctAnswer != card.correctAnswer }
                               .map { $0.correctAnswer }
                               .shuffled()
        if distractors.count > totalOptionsCount - 1 {
            distractors = Array(distractors.prefix(totalOptionsCount - 1))
        }
        var options = distractors + [card.correctAnswer]
        options.shuffle()
        return options
    }
    
    private func updateCardLearningStatus(for card: MultipleChoiceCard, learned: Bool) {
        guard let cardSet = cardSet,
              let cardObjects = cardSet.cards?.allObjects as? [Card] else { return }
        if let coreCard = cardObjects.first(where: { ($0.question ?? "") == card.question && ($0.answer ?? "") == card.correctAnswer }) {
            coreCard.isLearned = learned
        }
    }
    
    private func saveContext() {
        guard let context = cardSet?.managedObjectContext else { return }
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения контекста: \(error)")
        }
    }
}
