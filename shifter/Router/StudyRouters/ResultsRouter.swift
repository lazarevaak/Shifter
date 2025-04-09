import UIKit

// MARK: - Router

final class ResultsRouter: ResultsRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: ResultsViewController?

    // MARK: - Routing Logic
    func routeDismiss() {
        viewController?.dismiss(animated: true, completion: viewController?.onDismiss)
    }
}
