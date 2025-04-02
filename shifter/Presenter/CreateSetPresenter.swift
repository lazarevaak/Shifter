import UIKit

protocol CreateSetPresentationLogic {
    func presentCreateSet(response: CreateSet.Response)
}

final class CreateSetPresenter: CreateSetPresentationLogic {
    weak var viewController: CreateSetDisplayLogic?
    
    func presentCreateSet(response: CreateSet.Response) {
        let message: String
        if response.success {
            message = "Set created successfully!"
        } else {
            message = response.errorMessage ?? "An error occurred."
        }
        let viewModel = CreateSet.ViewModel(message: message)
        DispatchQueue.main.async {
            self.viewController?.displayCreateSet(viewModel: viewModel)
        }
    }
}
