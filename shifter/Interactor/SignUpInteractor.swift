import UIKit
import CoreData

final class SignUpInteractor: SignUpBusinessLogic {
    var presenter: SignUpPresentationLogic?
    
    func signUp(request: SignUp.Request) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            let response = SignUp.Response(success: false, errorMessage: "Ошибка приложения")
            presenter?.presentSignUp(response: response)
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", request.email)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                let response = SignUp.Response(success: false, errorMessage: "Пользователь с таким email уже существует.")
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
            let response = SignUp.Response(success: false, errorMessage: "Ошибка доступа к базе. Попробуйте позже.")
            presenter?.presentSignUp(response: response)
        }
    }
}
