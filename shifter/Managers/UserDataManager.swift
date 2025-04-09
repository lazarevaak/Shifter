import UIKit
import CoreData

class UserDataManager {
    // MARK: - Singleton
    static let shared = UserDataManager()
    
    // MARK: - Core Data Context
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Update Methods
    
    func updateUsername(for userId: String, newName: String, completion: (Bool) -> Void) {
        guard let url = URL(string: userId),
              let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {
            completion(false)
            return
        }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
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
            completion(false)
        }
    }
    
    func updatePassword(for userId: String, newPassword: String, completion: (Bool) -> Void) {
        guard let url = URL(string: userId),
              let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {
            completion(false)
            return
        }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF == %@", objectID)
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first {
                userEntity.password = newPassword
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            completion(false)
        }
    }
    
    func updateEmail(for userId: String, newEmail: String, completion: (Bool) -> Void) {
        guard let url = URL(string: userId),
              let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {
            completion(false)
            return
        }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF == %@", objectID)
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first {
                userEntity.email = newEmail
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            completion(false)
        }
    }
    
    func updateLanguage(for userId: String, newLanguage: String, completion: (Bool) -> Void) {
        guard let url = URL(string: userId),
              let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {
            completion(false)
            return
        }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "SELF == %@", objectID)
        do {
            let results = try context.fetch(fetchRequest)
            if let userEntity = results.first {
                userEntity.language = newLanguage
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            completion(false)
        }
    }
    
    // MARK: - Validation Method
    
    func userExists(withEmail email: String, excludingUserId: String, completion: (Bool) -> Void) {
        guard let url = URL(string: excludingUserId),
              let currentObjectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {
            completion(false)
            return
        }
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND SELF != %@", email, currentObjectID)
        
        do {
            let results = try context.fetch(fetchRequest)
            completion(!results.isEmpty)
        } catch {
            completion(false)
        }
    }
}
