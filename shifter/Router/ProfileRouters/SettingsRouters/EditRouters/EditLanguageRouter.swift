import UIKit

// MARK: - Router

final class EditLanguageRouter: EditLanguageRoutingLogic {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    
    // MARK: - Routing Logic
    func routeToPreviousScreen() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
