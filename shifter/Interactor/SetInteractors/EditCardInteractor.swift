import UIKit
import CoreData
import Foundation
import OSLog

// MARK: - Module: EditCard
enum EditCard {
    enum UpdateCard {
        struct Request {
            let question: String
            let answer: String
        }
        
        struct Response {
            let card: Card
        }
        
        struct ViewModel {
            let card: Card
        }
    }
}

// MARK: - Business Logic
protocol EditCardBusinessLogic {
    func updateCard(request: EditCard.UpdateCard.Request)
}

// MARK: - Routing Logic
protocol EditCardRoutingLogic {
    func routeToPreviousScreen()
}

// MARK: - Presentation Logic
protocol EditCardPresentationLogic: AnyObject {
    func presentUpdatedCard(response: EditCard.UpdateCard.Response)
}

// MARK: - Display Logic
protocol EditCardDisplayLogic: AnyObject {
    func displayUpdatedCard(viewModel: EditCard.UpdateCard.ViewModel)
}

// MARK: - Delegate Protocol for Edit CardSet
protocol EditCardSetViewControllerDelegate: AnyObject {
    func editCardSetViewController(_ controller: EditCardSetViewController, didUpdateCardSet cardSet: CardSet)
}

// MARK: - Delegate Protocol for Edit Card
protocol EditCardViewControllerDelegate: AnyObject {
    func editCardViewController(_ controller: EditCardViewController, didUpdateCard card: Card)
    func editCardSetViewController(_ controller: EditCardSetViewController, didUpdateCardSet cardSet: CardSet)
}

// MARK: - Interactor
class EditCardInteractor: EditCardBusinessLogic {
    var presenter: EditCardPresentationLogic?
    
    var card: Card

    init(card: Card) {
        self.card = card
    }
    
    func updateCard(request: EditCard.UpdateCard.Request) {
        card.question = request.question
        card.answer = request.answer
        
        guard let context = card.managedObjectContext else {
            os_log("ManagedObjectContext is nil. Убедитесь, что объект card добавлен в Core Data Stack.",
                   log: OSLog.default, type: .error)
            return
        }
        
        do {
            try context.save()
            os_log("Card saved successfully", log: OSLog.default, type: .info)
        } catch {
            os_log("Error saving card: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
        }
        
        let response = EditCard.UpdateCard.Response(card: card)
        presenter?.presentUpdatedCard(response: response)
    }
}
