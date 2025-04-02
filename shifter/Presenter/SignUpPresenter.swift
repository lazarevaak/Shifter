import UIKit

enum SignUp {
    struct Request {
        let name: String
        let email: String
        let password: String
    }
    struct Response {
        let success: Bool
        let errorMessage: String?
    }
    struct ViewModel {
        let message: String
    }
}

protocol SignUpBusinessLogic {
    func signUp(request: SignUp.Request)
}

protocol SignUpPresentationLogic {
    func presentSignUp(response: SignUp.Response)
}

protocol SignUpDisplayLogic: AnyObject {
    func displaySignUp(viewModel: SignUp.ViewModel)
}


final class SignUpPresenter: SignUpPresentationLogic {
    weak var viewController: SignUpDisplayLogic?
    
    func presentSignUp(response: SignUp.Response) {
        let message: String
        if response.success {
            message = "Registration successful!"
        } else {
            message = response.errorMessage ?? "Registration failed."
        }
        let viewModel = SignUp.ViewModel(message: message)
        viewController?.displaySignUp(viewModel: viewModel)
    }
}

