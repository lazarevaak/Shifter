import UIKit
import CoreData

// MARK: - Models
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

// MARK: - Protocols

// MARK: Business Logic
protocol SignUpBusinessLogic {
    func signUp(request: SignUp.Request)
}

// MARK: Routing Logic
protocol SignUpRoutingLogic {
    func routeToSignIn()
}

// MARK: Presentation Logic
protocol SignUpPresentationLogic {
    func presentSignUp(response: SignUp.Response)
}

// MARK: Display Logic
protocol SignUpDisplayLogic: AnyObject {
    func displaySignUp(viewModel: SignUp.ViewModel)
}

// MARK: - Interactor
final class SignUpInteractor: SignUpBusinessLogic {
    
    // MARK: - Properties
    var presenter: SignUpPresentationLogic?
    
    // MARK: - Business Logic
    func signUp(request: SignUp.Request) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            let response = SignUp.Response(success: false, errorMessage: "error_app".localized)
            presenter?.presentSignUp(response: response)
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", request.email)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                let response = SignUp.Response(success: false, errorMessage: "user_already_exists_message".localized)
                presenter?.presentSignUp(response: response)
                return
            }

            let newUser = User(context: context)
            newUser.email = request.email
            newUser.password = request.password
            newUser.name = request.name
            
            try context.save()
            let response = SignUp.Response(success: true, errorMessage: nil)
            presenter?.presentSignUp(response: response)
            
        } catch {
            let response = SignUp.Response(success: false, errorMessage: "database_later_message".localized)
            presenter?.presentSignUp(response: response)
        }
    }
}
