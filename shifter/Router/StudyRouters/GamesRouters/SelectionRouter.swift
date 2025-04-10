import UIKit

// MARK: - Router
class SelectionRouter: SelectionRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToResults(correctCount: Int, total: Int) {
        let pct = Int(Float(correctCount) / Float(total) * 100)
        let resultsVC = ResultsViewController.instantiate(
            leftScore: 0,
            rightScore: total,
            progress: pct
        ) { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        viewController?.present(resultsVC, animated: true)
    }
}
