import UIKit
import CoreData
import Compression
import os.log

// MARK: - UIViewController Extension for Top Most Controller
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController,
           let visible = nav.visibleViewController {
            return visible.topMostViewController()
        }
        if let tab = self as? UITabBarController,
           let selected = tab.selectedViewController {
            return selected.topMostViewController()
        }
        return self
    }
}

// MARK: - SceneDelegate
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - UIScene Lifecycle
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let splash = SplashViewController()
        splash.window = window

        window.rootViewController = splash
        window.makeKeyAndVisible()

        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func scene(_ scene: UIScene,
               openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        handleIncomingURL(urlContext.url)
    }

    // MARK: - Deep Link Handling
    private func handleIncomingURL(_ url: URL) {
        let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.example.myapp",
                           category: "URLHandler")
        os_log("Received URL: %{public}@",
               log: logger, type: .debug, url.absoluteString)

        guard url.scheme == "myapp", url.host == "createSet" else {
            return
        }

        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let dataItem = components.queryItems?.first(where: { $0.name == "d" })?.value,
            let percentDecoded = dataItem.removingPercentEncoding,
            let compressed = Data(base64Encoded: percentDecoded),
            let jsonData = compressed.decompressed(using: COMPRESSION_ZLIB)
        else {
            os_log("Failed to extract or decode 'd' parameter",
                   log: logger, type: .error)
            return
        }

        os_log("Decompressed JSON data, size: %{public}d bytes",
               log: logger, type: .debug, jsonData.count)

        do {
            let context = (UIApplication.shared.delegate as! AppDelegate)
                          .persistentContainer.viewContext
            guard
                let dict = try JSONSerialization
                            .jsonObject(with: jsonData) as? [String: Any],
                let entity = NSEntityDescription
                            .entity(forEntityName: "CardSet", in: context)
            else {
                os_log("JSON parsing or entity creation failed",
                       log: logger, type: .error)
                return
            }

            // Создаём и сохраняем CardSet
            let cardSet = CardSet(entity: entity, insertInto: context)
            cardSet.name           = dict["n"] as? String
            cardSet.setDescription = dict["d"] as? String
            cardSet.textOfSet      = dict["t"] as? String

            if let cardsArray = dict["c"] as? [[String: String]] {
                cardsArray.forEach { info in
                    guard let cardEntity = NSEntityDescription
                            .entity(forEntityName: "Card", in: context) else {
                        return
                    }
                    let card = Card(entity: cardEntity, insertInto: context)
                    card.question = info["q"]
                    card.answer   = info["a"]
                    cardSet.addToCards(card)
                }
            }

            try context.save()

            let setVC = SetDetailsViewController(cardSet: cardSet)
            setVC.isDownloadMode = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let top = self.window?.rootViewController?
                                 .topMostViewController() {
                    top.present(setVC, animated: true) {
                        os_log("SetDetailsViewController presented",
                               log: logger, type: .debug)
                    }
                } else {
                    os_log("Failed to find topMostViewController",
                           log: logger, type: .error)
                }
            }
        } catch {
            os_log("Error handling deep link: %{public}@",
                   log: logger, type: .error, error.localizedDescription)
        }
    }
}
