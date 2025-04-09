import UIKit

// MARK: - Presenter
final class EditEmailPresenter: EditEmailPresentationLogic {

    // MARK: - Properties
    weak var viewController: EditEmailDisplayLogic?

    // MARK: - Presentation Logic
    func presentUpdateEmail(response: EditEmailModels.UpdateEmail.Response) {
        let viewModel: EditEmailModels.UpdateEmail.ViewModel
        if response.success {
            viewModel = EditEmailModels.UpdateEmail.ViewModel(
                success: true,
                message: "email_update_success".localized
            )
        } else {
            viewModel = EditEmailModels.UpdateEmail.ViewModel(
                success: false,
                message: response.errorMessage ?? "error_default".localized
            )
        }
        viewController?.displayUpdateEmail(viewModel: viewModel)
    }
}

