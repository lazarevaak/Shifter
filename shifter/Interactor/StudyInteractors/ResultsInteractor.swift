import UIKit

// MARK: - Models

enum Results {
    enum Fetch {
        struct Request {}
        struct Response {
            let leftScore: Int
            let rightScore: Int
            let progress: Int
        }
        struct ViewModel {
            let titleText: String
            let resultsText: String
        }
    }
}

// MARK: - Display Logic Protocol

protocol ResultsDisplayLogic: AnyObject {
    func displayResults(viewModel: Results.Fetch.ViewModel)
}

// MARK: - Business Logic Protocols

protocol ResultsBusinessLogic {
    func fetchResults(request: Results.Fetch.Request)
}

protocol ResultsDataStore {
    var leftScore: Int { get set }
    var rightScore: Int { get set }
    var progress: Int { get set }
}

protocol ResultsPresentationLogic {
    func presentResults(response: Results.Fetch.Response)
}

protocol ResultsRoutingLogic: AnyObject {
    func routeDismiss()
}

// MARK: - Interactor

final class ResultsInteractor: ResultsBusinessLogic, ResultsDataStore {
    var presenter: ResultsPresentationLogic?

    var leftScore: Int = 0
    var rightScore: Int = 0
    var progress: Int = 0

    func fetchResults(request: Results.Fetch.Request) {
        let response = Results.Fetch.Response(
            leftScore: leftScore,
            rightScore: rightScore,
            progress: progress
        )
        presenter?.presentResults(response: response)
    }
}
