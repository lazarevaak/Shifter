import UIKit
import CoreData

// MARK: - Models
enum CreateSet {
    struct Request {
        let name: String
        let description: String
        let text: String
    }
    
    struct Response {
        let success: Bool
        let errorMessage: String?
    }
    
    struct ViewModel {
        let message: String
    }
}

// MARK: - Protocols

// MARK: - Business Logic
protocol CreateSetBusinessLogic {
    func createSet(request: CreateSet.Request)
}

// MARK: - Routing Logic
protocol CreateSetRoutingLogic {
    func routeToProfile(with user: User)
}

// MARK: - Presentation Logic
protocol CreateSetPresentationLogic {
    func presentCreateSet(response: CreateSet.Response)
}

// MARK: - Display Logic
protocol CreateSetDisplayLogic: AnyObject {
    func displayCreateSet(viewModel: CreateSet.ViewModel)
}

// MARK: - Interactor
final class CreateSetInteractor: CreateSetBusinessLogic {
    var presenter: CreateSetPresentationLogic?
    let currentUser: User
    
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    func createSet(request: CreateSet.Request) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            DispatchQueue.main.async {
                let response = CreateSet.Response(success: false, errorMessage: "error_app".localized)
                self.presenter?.presentCreateSet(response: response)
            }
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        var didComplete = false
        let timeoutWorkItem = DispatchWorkItem {
            if !didComplete {
                didComplete = true
                DispatchQueue.main.async {
                    let response = CreateSet.Response(success: false, errorMessage: "time_limit_error".localized)
                    self.presenter?.presentCreateSet(response: response)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutWorkItem)
        
        generateFlashcards(from: request.text) { flashcards in
            DispatchQueue.main.async {
                if didComplete { return }
                didComplete = true
                timeoutWorkItem.cancel()
                
                guard !flashcards.isEmpty else {
                    let response = CreateSet.Response(success: false, errorMessage: "generation_error".localized)
                    self.presenter?.presentCreateSet(response: response)
                    return
                }
                
                let newSet = CardSet(context: context)
                newSet.id = UUID()
                newSet.name = request.name
                newSet.setDescription = request.description
                newSet.textOfSet = request.text
                newSet.owner = self.currentUser
                
                for flashcard in flashcards {
                    let card = Card(context: context)
                    card.id = UUID()
                    card.question = flashcard["question"] ?? ""
                    card.answer = flashcard["answer"] ?? ""
                    card.set = newSet
                }
                
                do {
                    try context.save()
                    let response = CreateSet.Response(success: true, errorMessage: nil)
                    self.presenter?.presentCreateSet(response: response)
                } catch {
                    let response = CreateSet.Response(success: false, errorMessage: "save_data_error".localized + "\(error.localizedDescription)")
                    self.presenter?.presentCreateSet(response: response)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func generateFlashcards(from text: String, completion: @escaping ([[String: String]]) -> Void) {
        let prompt = """
        На основе данного текста, создай не более 10 карточек для изучения.
        Для каждой карточки сформулируй вопрос и краткий ответ.
        Текст:
        \(text)
        Ответ должен быть в формате JSON: [{"question": "Вопрос 1", "answer": "Ответ 1"}, ...]
        """
        
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let openRouterAPIKey = Bundle.main.object(forInfoDictionaryKey: "OpenRouterAPIKey") as? String else {
            completion([])
            return
        }
        request.addValue("Bearer \(openRouterAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("https://your-site.example", forHTTPHeaderField: "HTTP-Referer")
        request.addValue("Your App Name", forHTTPHeaderField: "X-Title")
        
        let requestBody: [String: Any] = [
            "model": "deepseek/deepseek-chat-v3-0324:free",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data,
                  let rawResponse = String(data: data, encoding: .utf8) else {
                completion([])
                return
            }
            
            let cleaned = self.cleanJSON(rawResponse)
            do {
                if let jsonData = cleaned.data(using: .utf8),
                   let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    
                    if let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        let cleanedContent = self.cleanJSON(content)
                        if let contentData = cleanedContent.data(using: .utf8),
                           let flashcards = try JSONSerialization.jsonObject(with: contentData, options: []) as? [[String: String]] {
                            completion(flashcards)
                            return
                        }
                    }
                    completion([])
                } else {
                    completion([])
                }
            } catch {
                print("Ошибка парсинга JSON: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }
    
    private func cleanJSON(_ text: String) -> String {
        var cleaned = text.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
