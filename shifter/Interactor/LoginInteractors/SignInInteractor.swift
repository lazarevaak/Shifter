import UIKit
import CoreData

// MARK: - SignIn Models
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

// MARK: - Protocols

// MARK: - Business Logic Protocol
protocol SignInBusinessLogic {
    func signIn(request: SignIn.Request)
}

// MARK: - Presentation Logic Protocol
protocol SignInPresentationLogic {
    func presentSignIn(response: SignIn.Response)
}

// MARK: - Display Logic Protocol
protocol SignInDisplayLogic: AnyObject {
    func displaySignIn(viewModel: SignIn.ViewModel)
}

// MARK: - Routing Logic Protocol
protocol SignInRoutingLogic {
    func routeToForgotPassword()
    func routeToSignUp()
    func routeToProfile(with user: User)
}

// MARK: - Interactor
final class SignInInteractor: SignInBusinessLogic {
    
    // MARK: - Properties
    var presenter: SignInPresentationLogic?
    
    // MARK: - Business Logic
    func signIn(request: SignIn.Request) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            let response = SignIn.Response(
                success: false,
                user: nil,
                errorMessage: "Ошибка приложения"
            )
            presenter?.presentSignIn(response: response)
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", request.email)
        
        do {
            let users = try context.fetch(fetchRequest)
            
            if let user = users.first {
                if user.password == request.password {
                    let response = SignIn.Response(
                        success: true,
                        user: user,
                        errorMessage: nil
                    )
                    presenter?.presentSignIn(response: response)
                } else {
                    let response = SignIn.Response(
                        success: false,
                        user: nil,
                        errorMessage: "Неверный пароль."
                    )
                    presenter?.presentSignIn(response: response)
                }
            } else {
                let response = SignIn.Response(
                    success: false,
                    user: nil,
                    errorMessage: "Пользователь не найден."
                )
                presenter?.presentSignIn(response: response)
            }
        } catch {
            let response = SignIn.Response(
                success: false,
                user: nil,
                errorMessage: "Ошибка доступа к данным."
            )
            presenter?.presentSignIn(response: response)
        }
    }
}
