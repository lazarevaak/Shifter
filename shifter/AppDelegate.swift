import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "UserDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Ошибка загрузки хранилища: \(error)")
            }
        }
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Обработка входящего URL для кастомной схемы
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Проверяем, что схема и хост соответствуют нашим
        if url.scheme == "myapp", url.host == "createSet" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let dataItem = queryItems.first(where: { $0.name == "data" })?.value,
               let decodedData = dataItem.removingPercentEncoding,
               let jsonData = decodedData.data(using: .utf8) {
                do {
                    if let setData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        // Здесь реализуйте переход на экран создания набора с полученными данными
                        print("Получены данные набора: \(setData)")
                        // Например, можно отправить уведомление:
                        NotificationCenter.default.post(name: Notification.Name("CreateSetWithData"), object: nil, userInfo: setData)
                    }
                } catch {
                    print("Ошибка парсинга JSON: \(error)")
                }
            }
        }
        return true
    }
}

