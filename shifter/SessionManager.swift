import UIKit
import CoreData

final class SessionManager {
    static let shared = SessionManager()
    
    var currentUser: User? {
        guard let savedEmail = UserDefaults.standard.string(forKey: "LoggedInUserEmail") else {
            return nil
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", savedEmail)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first 
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return nil
        }
    }
    
    func setLoggedInUser(_ user: User) {
        UserDefaults.standard.set(user.email, forKey: "LoggedInUserEmail")
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
    }
    
    func signOut() {
        print("signOut called")
        UserDefaults.standard.removeObject(forKey: "LoggedInUserEmail")
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
    }
}
