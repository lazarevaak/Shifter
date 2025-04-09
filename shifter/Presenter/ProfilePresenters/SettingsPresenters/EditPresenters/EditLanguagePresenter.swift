import Foundation

// MARK: - Presenter
final class EditLanguagePresenter: EditLanguagePresentationLogic {

    // MARK: - Properties
    weak var viewController: EditLanguageDisplayLogic?

    // MARK: - Presentation Logic
    func presentUpdateLanguage(response: EditLanguageModels.UpdateLanguage.Response) {
        let viewModel = EditLanguageModels.UpdateLanguage.ViewModel(
            success: response.success,
            message: response.message ?? ""
        )
        viewController?.displayUpdateLanguage(viewModel: viewModel)
    }
}
