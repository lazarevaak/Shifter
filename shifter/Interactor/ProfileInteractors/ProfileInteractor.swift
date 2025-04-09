import UIKit
import CoreData

// MARK: - Models
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

// MARK: - Protocols

// MARK: Display Logic
protocol ProfileDisplayLogic: AnyObject {
    func displayProfile(viewModel: Profile.ViewModel)
}

// MARK: Business Logic
protocol ProfileBusinessLogic {
    func fetchProfile(request: Profile.Request)
    func updateAvatar(request: Profile.UpdateAvatarRequest)
}

// MARK: Presentation Logic
protocol ProfilePresentationLogic {
    func presentProfile(response: Profile.Response)
}

// MARK: Routing Logic
protocol ProfileRoutingLogic {
    func routeToSettings(with user: User)
    func routeToSetsScreen(with user: User)
    func routeToCreateSet(with user: User)
}

// MARK: - Interactor
final class ProfileInteractor: ProfileBusinessLogic {
    
    // MARK: - Properties
    var presenter: ProfilePresentationLogic?
    var user: User
    private let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    // MARK: - Init
    init(user: User) {
        self.user = user
    }
    
    // MARK: - Business Logic
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
