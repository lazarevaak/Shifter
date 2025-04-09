import UIKit
import CoreData
import os.log

// MARK: - Router

final class StudyRouter {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    var cardSet: CardSet?
    
    // MARK: - Routing Logic
    func routeToNextScreen(for menuItem: StudyModels.MenuItemViewModel) {
        var destinationVC: UIViewController?
        
        switch menuItem.id {
        case 1:
            if let cs = cardSet {
                destinationVC = CardsViewController(cardSet: cs)
            } else {
                os_log("CardSet не установлен")
            }
        case 2:
            if let cs = cardSet {
                destinationVC = MemorizationViewController(cardSet: cs)
            } else {
                os_log("CardSet не установлен")
            }
        case 3:
            if let cs = cardSet {
                destinationVC = TestViewController(cardSet: cs)
            } else {
                os_log("CardSet не установлен")
            }
        case 4:
            if let cs = cardSet {
                destinationVC = SelectionViewController(cardSet: cs)
            } else {
                os_log("CardSet не установлен")
            }
        default:
            os_log("Неподдерживаемый id меню: %d", menuItem.id)
        }
        
        if var setReceiver = destinationVC as? SetDataReceivable {
            setReceiver.setID = menuItem.id
        }
        
        if let vc = destinationVC {
            vc.modalPresentationStyle = .fullScreen
            viewController?.present(vc, animated: true, completion: nil)
        }
    }
}
