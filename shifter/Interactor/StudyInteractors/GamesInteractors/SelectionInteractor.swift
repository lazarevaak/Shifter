import UIKit
import CoreData

// MARK: - Models

enum Selection {

    // MARK: — Load Use Case
    enum Load {
        struct Request {}
        struct Response {
            let questions: [Card]
            let answers: [Card]
            let total: Int
        }
        struct ViewModel {
            let questionTexts: [String]
            let answerTexts: [String]
        }
    }

    // MARK: — Evaluate Use Case
    enum Evaluate {
        struct Request {
            let questionIndex: Int
            let answerIndex: Int
        }
        struct Response {
            let questionIndex: Int
            let answerIndex: Int
            let isCorrect: Bool
            let questions: [Card]
            let answers: [Card]
            let correctCount: Int
            let total: Int
        }
        struct ViewModel {
            let questionIndex: Int
            let answerIndex: Int
            let isCorrect: Bool
            let questionTexts: [String]
            let answerTexts: [String]
            let correctCount: Int
            let total: Int
        }
    }
}

// MARK: - Protocols

// MARK: - Business Logic
protocol SelectionBusinessLogic {
    func load(request: Selection.Load.Request)
    func evaluate(request: Selection.Evaluate.Request)
}

// MARK: - Presentation Logic
protocol SelectionPresentationLogic {
    func presentLoad(response: Selection.Load.Response)
    func presentEvaluation(response: Selection.Evaluate.Response)
}

// MARK: - Display Logic
protocol SelectionDisplayLogic: AnyObject {
    func displayLoad(viewModel: Selection.Load.ViewModel)
    func displayEvaluation(viewModel: Selection.Evaluate.ViewModel)
}

// MARK: - Routing Logic
protocol SelectionRoutingLogic {
    func routeToResults(correctCount: Int, total: Int)
}

// MARK: - Data Store
protocol SelectionDataStore {
    var cardSet: CardSet? { get set }
}

// MARK: - Interactor
class SelectionInteractor: SelectionBusinessLogic, SelectionDataStore {
    var presenter: SelectionPresentationLogic?
    var cardSet: CardSet?

    private var allCards: [Card] = []
    private var shuffledQuestions: [Card] = []
    private var shuffledAnswers: [Card] = []
    private var total: Int = 0
    private var correctCount: Int = 0
    
    // MARK: - Init
    init(cardSet: CardSet?) {
        self.cardSet = cardSet
    }
    
    // MARK: - Load 
    func load(request: Selection.Load.Request) {
        guard let set = cardSet,
              let cards = set.cards?.allObjects as? [Card] else {
            presenter?.presentLoad(response: .init(questions: [], answers: [], total: 0))
            return
        }
        allCards = cards
        total = cards.count
        correctCount = 0
        shuffledQuestions = cards.shuffled()
        shuffledAnswers   = cards.shuffled()

        let response = Selection.Load.Response(
            questions: shuffledQuestions,
            answers: shuffledAnswers,
            total: total
        )
        presenter?.presentLoad(response: response)
    }

    func evaluate(request: Selection.Evaluate.Request) {
        let qIdx = request.questionIndex
        let aIdx = request.answerIndex
        let qCard = shuffledQuestions[qIdx]
        let aCard = shuffledAnswers[aIdx]
        let isCorrect = (qCard.objectID == aCard.objectID)

        if isCorrect {
            correctCount += 1
            qCard.isLearned = true
            shuffledQuestions.remove(at: qIdx)
            shuffledAnswers.removeAll { $0.objectID == aCard.objectID }
        }

        let response = Selection.Evaluate.Response(
            questionIndex: qIdx,
            answerIndex: aIdx,
            isCorrect: isCorrect,
            questions: shuffledQuestions,
            answers: shuffledAnswers,
            correctCount: correctCount,
            total: total
        )
        presenter?.presentEvaluation(response: response)
    }
}

