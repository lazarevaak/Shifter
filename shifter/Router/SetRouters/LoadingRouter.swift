import UIKit

// MARK: - Router

final class LoadingRouter: LoadingRoutingLogic, LoadingDataPassing {
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    var dataStore: LoadingDataStore?
}
