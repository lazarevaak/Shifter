import UIKit

// MARK: - Presenter
final class LoadingPresenter: LoadingPresentationLogic {

    // MARK: - Properties
    weak var viewController: LoadingDisplayLogic?

    // MARK: - Presentation Logic
    func presentShowResult(response: Loading.ShowResult.Response) {
        let viewModel = Loading.ShowResult.ViewModel(
            message: response.message,
            isSuccess: response.isSuccess
        )
        viewController?.displayShowResult(viewModel: viewModel)
    }
}
