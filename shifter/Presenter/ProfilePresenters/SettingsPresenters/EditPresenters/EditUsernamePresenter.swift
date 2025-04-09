import Foundation

// MARK: - Presenter

final class EditUsernamePresenter: EditUsernamePresentationLogic {

    // MARK: - Properties

    weak var viewController: EditUsernameDisplayLogic?

    // MARK: - Presentation Logic

    func presentUpdateUsername(response: EditUsernameModels.UpdateUsername.Response) {
        let viewModel = EditUsernameModels.UpdateUsername.ViewModel(
            success: response.success,
            message: response.message ?? ""
        )
        viewController?.displayUpdateUsername(viewModel: viewModel)
    }
}

