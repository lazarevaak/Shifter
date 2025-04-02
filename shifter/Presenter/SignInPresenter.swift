import UIKit

enum SignIn {
    struct Request {
        let email: String
        let password: String
    }
    struct Response {
        let success: Bool
        let user: User?
        let errorMessage: String?
    }
    struct ViewModel {
        let message: String
        let user: User?
    }
}

protocol SignInBusinessLogic {
    func signIn(request: SignIn.Request)
}

protocol SignInPresentationLogic {
    func presentSignIn(response: SignIn.Response)
}

protocol SignInDisplayLogic: AnyObject {
    func displaySignIn(viewModel: SignIn.ViewModel)
}


final class SignInPresenter: SignInPresentationLogic {
    weak var viewController: SignInDisplayLogic?
    
    func presentSignIn(response: SignIn.Response) {
        if response.success {
            let message = "Добро пожаловать!"
            let viewModel = SignIn.ViewModel(message: message, user: response.user)
            viewController?.displaySignIn(viewModel: viewModel)
        } else {
            let message = response.errorMessage ?? "Произошла ошибка"
            let viewModel = SignIn.ViewModel(message: message, user: nil)
            viewController?.displaySignIn(viewModel: viewModel)
        }
    }
}
