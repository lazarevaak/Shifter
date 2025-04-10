import UIKit

// MARK: - Models

enum Loading {
    // MARK: ShowResult Models
    enum ShowResult {
        struct Request {
            let message: String
            let isSuccess: Bool
        }
        struct Response {
            let message: String
            let isSuccess: Bool
        }
        struct ViewModel {
            let message: String
            let isSuccess: Bool
        }
    }
}

// MARK: - Protocols

// MARK: Business Logic
protocol LoadingBusinessLogic {
    func showResult(request: Loading.ShowResult.Request)
}

// MARK: Data Store
protocol LoadingDataStore {
    var resultMessage: String? { get set }
}

// MARK: Display Logic
protocol LoadingDisplayLogic: AnyObject {
    func displayShowResult(viewModel: Loading.ShowResult.ViewModel)
}

// MARK: Presentation Logic
protocol LoadingPresentationLogic {
    func presentShowResult(response: Loading.ShowResult.Response)
}

// MARK: Routing Logic
protocol LoadingRoutingLogic {}

// MARK: Data Passing 
protocol LoadingDataPassing {
    var dataStore: LoadingDataStore? { get }
}

// MARK: - Interactor

final class LoadingInteractor: LoadingBusinessLogic, LoadingDataStore {
    var presenter: LoadingPresentationLogic?
    var resultMessage: String?

    func showResult(request: Loading.ShowResult.Request) {
        resultMessage = request.message
        let response = Loading.ShowResult.Response(message: request.message,
                                                   isSuccess: request.isSuccess)
        presenter?.presentShowResult(response: response)
    }
}
