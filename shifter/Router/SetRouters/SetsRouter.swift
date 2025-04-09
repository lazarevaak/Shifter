import UIKit

// MARK: - Router

final class SetsRouter {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToSetDetails(set: CardSet) {
        let detailsVC = SetDetailsViewController(cardSet: set)
        detailsVC.modalPresentationStyle = .fullScreen
        viewController?.present(detailsVC, animated: true)
    }
    
    func routeBack() {
        viewController?.dismiss(animated: true)
    }
}
