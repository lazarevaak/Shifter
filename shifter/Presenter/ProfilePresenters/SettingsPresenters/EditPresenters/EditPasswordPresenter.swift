import Foundation

// MARK: - Presenter
final class EditPasswordPresenter: EditPasswordPresentationLogic {

    // MARK: - Properties
    weak var viewController: EditPasswordDisplayLogic?

    // MARK: - Presentation Logic
    func presentUpdatePassword(response: EditPasswordModels.UpdatePassword.Response) {
        let viewModel = EditPasswordModels.UpdatePassword.ViewModel(
            success: response.success,
            message: response.message ?? ""
        )
        viewController?.displayUpdatePassword(viewModel: viewModel)
    }
}

