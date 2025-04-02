import UIKit
import CoreData

final class SignInInteractor: SignInBusinessLogic {
    var presenter: SignInPresentationLogic?
    
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
