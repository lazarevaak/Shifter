import UIKit

// MARK: - Models
enum AnswerReview {
    enum FetchResults {
        struct Request { }
        struct Response {
            let title: String
            let correctAnswers: Int
            let incorrectAnswers: Int
            let totalCards: Int
        }
        struct ViewModel {
            let title: String
            let resultsText: String
        }
    }
}

// MARK: - Protocols

// MARK: - Display Logic
protocol AnswerReviewDisplayLogic: AnyObject {
    func displayResults(viewModel: AnswerReview.FetchResults.ViewModel)
}

// MARK: - Business Logic
protocol AnswerReviewBusinessLogic {
    func fetchResults(request: AnswerReview.FetchResults.Request)
}

// MARK: - Presentation Logic
protocol AnswerReviewPresentationLogic {
    func presentResults(response: AnswerReview.FetchResults.Response)
}

// MARK: - Routing Logic
protocol AnswerReviewRoutingLogic {
    func routeToNext()
}

// MARK: - Data Store
protocol AnswerReviewDataStore {
    var title: String { get set }
    var correctAnswers: Int { get set }
    var incorrectAnswers: Int { get set }
    var totalCards: Int { get set }
}

// MARK: - Data Passing
protocol AnswerReviewDataPassing {
    var dataStore: AnswerReviewDataStore? { get }
}

// MARK: - Interactor
final class AnswerReviewInteractor: AnswerReviewBusinessLogic, AnswerReviewDataStore {

    // MARK: - Properties
    var presenter: AnswerReviewPresentationLogic?
    var title: String = ""
    var correctAnswers: Int = 0
    var incorrectAnswers: Int = 0
    var totalCards: Int = 0

    // MARK: - Business Logic
    func fetchResults(request: AnswerReview.FetchResults.Request) {
        let response = AnswerReview.FetchResults.Response(
            title: title,
            correctAnswers: correctAnswers,
            incorrectAnswers: incorrectAnswers,
            totalCards: totalCards
        )
        presenter?.presentResults(response: response)
    }
}
