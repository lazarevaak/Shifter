import UIKit
import CoreData

final class ResetPasswordInteractor: ResetPasswordBusinessLogic {
    var presenter: ResetPasswordPresentationLogic?
    
    func resetPassword(request: ResetPassword.Request) {
        let storedCode = UserDefaults.standard.string(forKey: "ResetCode_\(request.email)")
        
        guard storedCode == request.code else {
            let response = ResetPassword.Response(success: false, errorMessage: "Неверный код восстановления.")
            presenter?.presentResetPassword(response: response)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            let response = ResetPassword.Response(success: false, errorMessage: "Ошибка приложения")
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
                let response = ResetPassword.Response(success: false, errorMessage: "Пользователь не найден.")
                presenter?.presentResetPassword(response: response)
            }
        } catch {
            let response = ResetPassword.Response(success: false, errorMessage: "Ошибка обновления пароля. Попробуйте позже.")
            presenter?.presentResetPassword(response: response)
        }
    }
}

