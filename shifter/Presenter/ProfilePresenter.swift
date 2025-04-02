import UIKit

// MARK: - Модель и энумы

enum Profile {
    struct Request { }
    
    struct Response {
        let user: User
    }
    
    struct ViewModel {
        let userName: String?
        let email: String?
    }
    
    struct UpdateAvatarRequest {
        let imageData: Data
    }
}

// MARK: - Протоколы

protocol ProfileDisplayLogic: AnyObject {
    func displayProfile(viewModel: Profile.ViewModel)
}

protocol ProfileBusinessLogic {
    func fetchProfile(request: Profile.Request)
    func updateAvatar(request: Profile.UpdateAvatarRequest)
}

protocol ProfilePresentationLogic {
    func presentProfile(response: Profile.Response)
}

protocol ProfileRoutingLogic {
    func routeToSettings(with user: User)
    func routeToSetsScreen(with user: User)
    func routeToCreateSet(with user: User)
}

// MARK: - Presenter

final class ProfilePresenter: ProfilePresentationLogic {
    weak var viewController: ProfileDisplayLogic?
    
    func presentProfile(response: Profile.Response) {
        let email = response.user.email
        let userName = response.user.name
        let viewModel = Profile.ViewModel(userName: userName, email: email)
        viewController?.displayProfile(viewModel: viewModel)
    }
}
