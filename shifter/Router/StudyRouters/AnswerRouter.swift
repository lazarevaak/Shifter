import UIKit

// MARK: - Router

final class AnswerReviewRouter: AnswerReviewRoutingLogic, AnswerReviewDataPassing {

    // MARK: - Properties
    weak var viewController: AnswerReviewViewController?
    var dataStore: AnswerReviewDataStore?

    // MARK: - Routing Logic
    func routeToNext() {
        viewController?.dismiss(animated: true) {
            self.viewController?.onNext?()
        }
    }
}
