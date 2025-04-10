import UIKit
import CoreData
import Foundation

// MARK: - Models

enum TestModels {
    struct TestRequest { }
    
    struct TestResponse {
        let question: String?
        let currentIndex: Int
        let totalCards: Int
        let progress: Float
        let isTestCompleted: Bool
        let correctAnswers: Int
        let incorrectAnswers: Int
    }
    
    struct TestViewModel {
        let questionText: String?
        let currentIndexText: String
        let totalCards: Int
        let progress: Float
        let isTestCompleted: Bool
        let correctAnswers: Int
        let incorrectAnswers: Int
    }
    
    struct CheckAnswerRequest {
        let userAnswer: String
    }
    
    struct CheckAnswerResponse {
        let resultMessage: String
        let correctAnswers: Int
        let incorrectAnswers: Int
        let totalCards: Int
        let isTestCompleted: Bool
    }
    
    struct CheckAnswerViewModel {
        let alertTitle: String
        let correctAnswers: Int
        let incorrectAnswers: Int
        let totalCards: Int
        let isTestCompleted: Bool
    }
}

// MARK: - Protocols

// MARK: - Business Logic
protocol TestBusinessLogic: AnyObject {
    func viewDidLoad(request: TestModels.TestRequest)
    func checkAnswer(request: TestModels.CheckAnswerRequest)
}

// MARK: - Routing Logic
protocol TestRoutingLogic {
    func routeToResults(correctAnswers: Int, total: Int)
}

// MARK: - Presentation Logic
protocol TestPresentationLogic: AnyObject {
    func presentTest(response: TestModels.TestResponse)
    func presentAnswer(response: TestModels.CheckAnswerResponse)
}

// MARK: - Display Logic
protocol TestDisplayLogic: AnyObject {
    func displayTest(viewModel: TestModels.TestViewModel)
    func displayAnswer(viewModel: TestModels.CheckAnswerViewModel)
}

// MARK: - Interactor
final class TestInteractor: TestBusinessLogic {
    var presenter: TestPresentationLogic?
    var cardSet: CardSet?
    var cards: [Card] = []
    var currentIndex = 0
    var correctAnswers = 0
    var incorrectAnswers = 0
    
    // MARK: - Init
    init(cardSet: CardSet?) {
        self.cardSet = cardSet
        if let set = cardSet, let cardObjects = set.cards?.allObjects as? [Card] {
            cards = cardObjects.sorted { ($0.question ?? "") < ($1.question ?? "") }
        }
    }
    
    func viewDidLoad(request: TestModels.TestRequest) {
        if currentIndex < cards.count {
            let card = cards[currentIndex]
            let response = TestModels.TestResponse(
                question: card.question,
                currentIndex: currentIndex,
                totalCards: cards.count,
                progress: Float(currentIndex + 1) / Float(cards.count),
                isTestCompleted: false,
                correctAnswers: correctAnswers,
                incorrectAnswers: incorrectAnswers
            )
            presenter?.presentTest(response: response)
        } else {
            let response = TestModels.TestResponse(
                question: nil,
                currentIndex: currentIndex,
                totalCards: cards.count,
                progress: 1.0,
                isTestCompleted: true,
                correctAnswers: correctAnswers,
                incorrectAnswers: incorrectAnswers
            )
            presenter?.presentTest(response: response)
        }
    }

    func checkAnswer(request: TestModels.CheckAnswerRequest) {
        guard currentIndex < cards.count else { return }
        let card = cards[currentIndex]
        
        let userAnswer = request.userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let correctAnswer = card.answer?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var resultMessage = ""
        if userAnswer.caseInsensitiveCompare(correctAnswer) == .orderedSame {
            resultMessage = "correctanswer_label".localized
            correctAnswers += 1
            card.isLearned = true
        } else {
            resultMessage = "incorrectanswer_label".localized + "\(correctAnswer)"
            card.isLearned = false
            incorrectAnswers += 1
        }
        
        if let context = card.managedObjectContext {
            do {
                try context.save()
            } catch {
                print("Error saving isLearned: \(error)")
            }
        }
        
        currentIndex += 1
        
        let response = TestModels.CheckAnswerResponse(
            resultMessage: resultMessage,
            correctAnswers: correctAnswers,
            incorrectAnswers: incorrectAnswers,
            totalCards: cards.count,
            isTestCompleted: currentIndex >= cards.count
        )
        presenter?.presentAnswer(response: response)
    }
}
