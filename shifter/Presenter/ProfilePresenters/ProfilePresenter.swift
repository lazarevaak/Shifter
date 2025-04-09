import UIKit

// MARK: - Presenter
final class ProfilePresenter: ProfilePresentationLogic {

    // MARK: - Properties
    weak var viewController: ProfileDisplayLogic?

    // MARK: - Presentation Logic
    func presentProfile(response: Profile.Response) {
        let email = response.user.email
        let userName = response.user.name
        let viewModel = Profile.ViewModel(userName: userName, email: email)
        viewController?.displayProfile(viewModel: viewModel)
    }
}
