import UIKit

// MARK: - Router
final class CardsRouter {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToResults(leftScore: Int, rightScore: Int, progress: Int) {
        let resultsVC = ResultsViewController.instantiate(
            leftScore: leftScore,
            rightScore: rightScore,
            progress: progress
        ) { [weak self] in
            self?.viewController?.dismiss(animated: true, completion: nil)
        }
        viewController?.present(resultsVC, animated: true, completion: nil)
    }
}
