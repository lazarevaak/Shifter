import UIKit

// MARK: - Router
final class TestRouter: TestRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToResults(correctAnswers: Int, total: Int) {
        let progressPercent = Int(Float(correctAnswers) / Float(total) * 100)
        let resultsVC = ResultsViewController.instantiate(
            leftScore: total - correctAnswers,
            rightScore: correctAnswers,
            progress: progressPercent
        ) { [weak self] in
            // просто закрываем текущий экран
            self?.viewController?.dismiss(animated: true, completion: nil)
        }
        viewController?.present(resultsVC, animated: true, completion: nil)
    }
}
