import UIKit
import CoreData

// MARK: - Interactor

final class ProfileInteractor: ProfileBusinessLogic {
    var presenter: ProfilePresentationLogic?
    var user: User
    
    private let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    init(user: User) {
        self.user = user
    }
    
    func fetchProfile(request: Profile.Request) {
        let response = Profile.Response(user: user)
        presenter?.presentProfile(response: response)
    }
    
    func updateAvatar(request: Profile.UpdateAvatarRequest) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", user.email ?? "")
        
        do {
            let results = try context.fetch(fetchRequest)
            if let foundUser = results.first {
                foundUser.avatarData = request.imageData
                try context.save()
                self.user = foundUser
            } else {
                print("Пользователь с email \(user.email ?? "nil") не найден")
            }
        } catch {
            print("Ошибка обновления аватара: \(error)")
        }
    }
}
