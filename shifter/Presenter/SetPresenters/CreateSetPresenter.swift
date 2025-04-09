import UIKit

// MARK: - Presenter
final class CreateSetPresenter: CreateSetPresentationLogic {

    // MARK: - Properties
    weak var viewController: CreateSetDisplayLogic?

    // MARK: - Presentation Logic
    func presentCreateSet(response: CreateSet.Response) {
        let message: String
        if response.success {
            message = "set_create_sucess_message".localized
        } else {
            message = response.errorMessage ?? "error_alert_title".localized
        }
        let viewModel = CreateSet.ViewModel(message: message)
        viewController?.displayCreateSet(viewModel: viewModel)
    }
}

