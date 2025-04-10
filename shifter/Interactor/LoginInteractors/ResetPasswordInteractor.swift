import UIKit
import CoreData

// MARK: - Models
enum ResetPassword {
    struct Request {
        let code: String
        let newPassword: String
        let email: String
    }
    
    struct Response {
        let success: Bool
        let errorMessage: String?
    }
    
    struct ViewModel {
        let message: String
        let success: Bool
    }
}

// MARK: - Protocols

// MARK: Business Logic
protocol ResetPasswordBusinessLogic {
    func resetPassword(request: ResetPassword.Request)
}

// MARK: Presentation Logic
protocol ResetPasswordPresentationLogic {
    func presentResetPassword(response: ResetPassword.Response)
}

// MARK: Display Logic
protocol ResetPasswordDisplayLogic: AnyObject {
    func displayResetPassword(viewModel: ResetPassword.ViewModel)
}

// MARK: Routing Logic
protocol ResetPasswordRoutingLogic {
    func routeToSignIn()
}

// MARK: - Interactor

final class ResetPasswordInteractor: ResetPasswordBusinessLogic {
    
    // MARK: - Properties
    var presenter: ResetPasswordPresentationLogic?
    
    // MARK: - Business Logic
    func resetPassword(request: ResetPassword.Request) {
        let storedCode = UserDefaults.standard.string(forKey: "ResetCode_\(request.email)")
        
        guard storedCode == request.code else {
            let response = ResetPassword.Response(success: false, errorMessage: "invalid_recovery_code".localized)
            presenter?.presentResetPassword(response: response)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            let response = ResetPassword.Response(success: false, errorMessage: "error_app".localized)
            presenter?.presentResetPassword(response: response)
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", request.email)
        
        do {
            if let user = try context.fetch(fetchRequest).first {
                user.password = request.newPassword
                try context.save()
                UserDefaults.standard.removeObject(forKey: "ResetCode_\(request.email)")
                
                let response = ResetPassword.Response(success: true, errorMessage: nil)
                presenter?.presentResetPassword(response: response)
            } else {
                let response = ResetPassword.Response(success: false, errorMessage: "usernotfound".localized)
                presenter?.presentResetPassword(response: response)
            }
        } catch {
            let response = ResetPassword.Response(success: false, errorMessage: "password_update_error".localized)
            presenter?.presentResetPassword(response: response)
        }
    }
}
