import Foundation
import UIKit


// MARK: - Presenter
final class MemorizationPresenter: MemorizationPresentationLogic {

    // MARK: - Properties
    weak var viewController: MemorizationDisplayLogic?
    var router: MemorizationRoutingLogic?

    // MARK: - Presentation Logic
    func presentCards(response: Memorization.LoadCards.ViewModel) {
        viewController?.displayCards(viewModel: response)
    }

    func presentOptionResult(isCorrect: Bool, viewModel: Memorization.LoadCards.ViewModel) {
        viewController?.displayOptionResult(viewModel: viewModel, isCorrect: isCorrect)
    }

    func presentError(message: String) {
        viewController?.displayError(message: message)
    }

    func presentFinish(correctAnswers: Int, total: Int) {
        guard let router = router else {
            fatalError("The router must be installed")
        }
        router.routeToResults(correctAnswers: correctAnswers, total: total)
    }
}

