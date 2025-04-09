import UIKit

// MARK: - Presenter
final class ConfirmActionPresenter: ConfirmActionPresentationLogic {

    // MARK: - Properties
    weak var viewController: ConfirmActionDisplayLogic?

    // MARK: - Presentation Logic
    func presentConfirmAction(response: ConfirmActionModels.Confirm.Response) {
        let viewModel: ConfirmActionModels.Confirm.ViewModel
        if response.isValid {
            viewModel = ConfirmActionModels.Confirm.ViewModel(
                success: true,
                message: "confirm_password_success".localized
            )
        } else {
            viewModel = ConfirmActionModels.Confirm.ViewModel(
                success: false,
                message: response.errorMessage ?? "error_default".localized
            )
        }
        viewController?.displayConfirmAction(viewModel: viewModel)
    }
}
