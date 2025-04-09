import UIKit

// MARK: - Presenter
final class AvatarSelectionPresenter: AvatarSelectionPresentationLogic {

    // MARK: - Properties
    weak var viewController: AvatarSelectionDisplayLogic?

    // MARK: - Presentation Logic
    func presentSaveAvatar(response: AvatarSelection.SaveAvatar.Response) {
        let viewModel = AvatarSelection.SaveAvatar.ViewModel(displayMessage: response.message ?? "")
        viewController?.displaySaveAvatar(viewModel: viewModel)
    }

    func presentAvatarIcons(response: AvatarSelection.FetchAvatarIcons.Response) {
        let viewModel = AvatarSelection.FetchAvatarIcons.ViewModel(icons: response.icons)
        viewController?.displayAvatarIcons(viewModel: viewModel)
    }
}
