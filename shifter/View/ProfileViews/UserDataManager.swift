import UIKit
import CoreData

class UserDataManager {
    static let shared = UserDataManager()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func updateUsername(for userId: String, newName: String, completion: (Bool) -> Void) {
        // Преобразуем строку в URL, а затем получаем NSManagedObjectID
        guard let url = URL(string: userId),
              let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {
            print("Invalid objectID URI: \(userId)")
            completion(false)
            return
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        // Используем предикат для поиска по objectID
        fetchRequest.predicate = NSPredicate(format: "SELF == %@", objectID)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first {
                userEntity.name = newName
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Error updating username: \(error)")
            completion(false)
        }
    }
}
