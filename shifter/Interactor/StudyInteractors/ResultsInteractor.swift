import UIKit

// MARK: - Models

enum Results {
    // MARK: Fetch Models
    enum Fetch {
        struct Request { }
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

// MARK: - Protocols

// MARK: - Display Logic
protocol ResultsDisplayLogic: AnyObject {
    func displayResults(viewModel: Results.Fetch.ViewModel)
}

// MARK: - Business Logic
protocol ResultsBusinessLogic {
    func fetchResults(request: Results.Fetch.Request)
}

// MARK: - Presentation Logic
protocol ResultsPresentationLogic {
    func presentResults(response: Results.Fetch.Response)
}

// MARK: - Routing Logic
protocol ResultsRoutingLogic: AnyObject {
    func routeDismiss()
}

// MARK: - Data Store 
protocol ResultsDataStore {
    var leftScore: Int { get set }
    var rightScore: Int { get set }
    var progress: Int { get set }
}

// MARK: - Interactor
final class ResultsInteractor: ResultsBusinessLogic, ResultsDataStore {
    var presenter: ResultsPresentationLogic?

    // MARK: Data Store Properties
    var leftScore: Int = 0
    var rightScore: Int = 0
    var progress: Int = 0

    // MARK: Fetch Results
    func fetchResults(request: Results.Fetch.Request) {
        let response = Results.Fetch.Response(
            leftScore: leftScore,
            rightScore: rightScore,
            progress: progress
        )
        presenter?.presentResults(response: response)
    }
}
