import UIKit

final class ProfileRouter: ProfileRoutingLogic {
    weak var viewController: UIViewController?
    
    func routeToSettings(with user: User) {
        let settingsVC = SettingsViewController(user: user)
        settingsVC.modalPresentationStyle = .fullScreen
        viewController?.present(settingsVC, animated: true, completion: nil)
    }
    
    func routeToSetsScreen(with user: User) {
        let setsVC = SetsViewController(currentUser: user)
        setsVC.modalPresentationStyle = .fullScreen
        viewController?.present(setsVC, animated: true, completion: nil)
    }
    
    func routeToCreateSet(with user: User) {
        let createSetVC = CreateSetViewController(currentUser: user)
        createSetVC.modalPresentationStyle = .fullScreen
        viewController?.present(createSetVC, animated: true, completion: nil)
    }
}
