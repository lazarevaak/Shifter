import Foundation
import UIKit
import CoreData

// MARK: - Models
enum ForgotPassword {
    struct Request {
        let email: String
    }
    
    struct Response {
        let success: Bool
        let message: String
    }
    
    struct ViewModel {
        let message: String
        let success: Bool
    }
}

// MARK: - Protocols

// MARK: Business Logic
protocol ForgotPasswordBusinessLogic {
    func sendResetCode(request: ForgotPassword.Request)
}

// MARK: Presentation Logic
protocol ForgotPasswordPresentationLogic {
    func presentForgotPassword(response: ForgotPassword.Response)
}

// MARK: Display Logic
protocol ForgotPasswordDisplayLogic: AnyObject {
    func displayForgotPassword(viewModel: ForgotPassword.ViewModel)
}

// MARK: Routing Logic
protocol ForgotPasswordRoutingLogic {
    func routeToResetPassword(with email: String)
}

// MARK: - Interactor
final class ForgotPasswordInteractor: ForgotPasswordBusinessLogic {
    
    // MARK: - Properties
    var presenter: ForgotPasswordPresentationLogic?
    
    // MARK: - Business Logic
    func sendResetCode(request: ForgotPassword.Request) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            let response = ForgotPassword.Response(success: false, message: "Ошибка приложения")
            presenter?.presentForgotPassword(response: response)
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", request.email)
        
        do {
            let users = try context.fetch(fetchRequest)
            if users.isEmpty {
                let response = ForgotPassword.Response(success: false, message: "Пользователь с таким email не найден.")
                presenter?.presentForgotPassword(response: response)
                return
            }
        } catch {
            let response = ForgotPassword.Response(success: false, message: "Ошибка доступа к данным.")
            presenter?.presentForgotPassword(response: response)
            return
        }
        
        let resetCode = String(format: "%06d", Int.random(in: 0...999999))
        UserDefaults.standard.set(resetCode, forKey: "ResetCode_\(request.email)")
        
        guard let url = URL(string: serverURL) else {
            let response = ForgotPassword.Response(success: false, message: "Неверный URL для отправки email.")
            presenter?.presentForgotPassword(response: response)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let body = ["email": request.email, "resetCode": resetCode]
        urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    let resp = ForgotPassword.Response(success: false, message: "Ошибка при отправке email: \(error.localizedDescription)")
                    self.presenter?.presentForgotPassword(response: resp)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let resp = ForgotPassword.Response(success: false, message: "Ошибка при отправке email.")
                    self.presenter?.presentForgotPassword(response: resp)
                    return
                }
                
                let resp = ForgotPassword.Response(success: true, message: "Код отправлен на email.")
                self.presenter?.presentForgotPassword(response: resp)
            }
        }.resume()
    }
    
    // MARK: - Private
    private var serverURL: String {
        #if targetEnvironment(simulator)
        return "http://127.0.0.1:3000/api/send_reset_code"
        #else
        return "http://192.168.1.11:3000/api/send_reset_code"
        #endif
    }
}
