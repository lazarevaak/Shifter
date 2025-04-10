import UIKit
import CoreData
import os.log
import Foundation

// MARK: - Models

enum SetDetails {
    // MARK: Fetch Cards Models
    enum FetchCards {
        struct Request { }
        struct Response {
            let cards: [Card]
        }
        struct ViewModel {
            let cardDescriptions: [String]
            let progressPercent: Int
        }
    }
    
    // MARK: Update Progress Models
    enum UpdateProgress {
        struct Request { }
        struct Response {
            let progressPercent: Int
        }
        struct ViewModel {
            let progressText: String
        }
    }
}

// MARK: - Protocols

// MARK: Business Logic Protocol
protocol SetDetailsBusinessLogic {
    func fetchCards(request: SetDetails.FetchCards.Request)
    func updateProgress(request: SetDetails.UpdateProgress.Request)
    func toggleLearned(for index: Int)
}

// MARK: Display Logic Protocol
protocol SetDetailsDisplayLogic: AnyObject {
    func displayFetchedCards(viewModel: SetDetails.FetchCards.ViewModel)
    func displayUpdatedProgress(viewModel: SetDetails.UpdateProgress.ViewModel)
}

// MARK: Routing Logic Protocol
protocol SetDetailsRoutingLogic {
    func dismiss()
}

// MARK: Presentation Logic Protocol
protocol SetDetailsPresentationLogic {
    func presentFetchedCards(response: SetDetails.FetchCards.Response)
    func presentUpdatedProgress(response: SetDetails.UpdateProgress.Response)
}

// MARK: - Interactor

final class SetDetailsInteractor: NSObject, SetDetailsBusinessLogic {
    // MARK: Properties
    var presenter: SetDetailsPresentationLogic?
    var cardSet: CardSet
    var context: NSManagedObjectContext
    
    // MARK: - Fetched Results Controller
    private lazy var fetchedResultsController: NSFetchedResultsController<Card> = {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "set == %@", cardSet)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "question", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    // MARK: - Initializer
    init(cardSet: CardSet, context: NSManagedObjectContext) {
        self.cardSet = cardSet
        self.context = context
        super.init()
    }
    
    // MARK: Fetch Cards
    func fetchCards(request: SetDetails.FetchCards.Request) {
        do {
            try fetchedResultsController.performFetch()
            let cards = fetchedResultsController.fetchedObjects ?? []
            let response = SetDetails.FetchCards.Response(cards: cards)
            presenter?.presentFetchedCards(response: response)
        } catch {
            os_log("Failed to fetch cards: %{public}@", type: .error, error.localizedDescription)
        }
    }
    
    // MARK: Update Progress
    func updateProgress(request: SetDetails.UpdateProgress.Request) {
        let cards = fetchedResultsController.fetchedObjects ?? []
        let total = cards.count
        let learnedCount = cards.filter { $0.isLearned }.count
        let progressPercent = total > 0 ? (learnedCount * 100 / total) : 0
        cardSet.progressOfSet = Int16(progressPercent)
        do {
            try context.save()
        } catch {
            os_log("Failed to save progress: %{public}@", type: .error, error.localizedDescription)
        }
        let response = SetDetails.UpdateProgress.Response(progressPercent: progressPercent)
        presenter?.presentUpdatedProgress(response: response)
    }
    
    // MARK: Toggle Learned State
    func toggleLearned(for index: Int) {
        guard let cards = fetchedResultsController.fetchedObjects, index < cards.count else { return }
        let card = cards[index]
        card.isLearned.toggle()
        do {
            try context.save()
        } catch {
            os_log("Failed to save card state: %{public}@", type: .error, error.localizedDescription)
        }
        updateProgress(request: SetDetails.UpdateProgress.Request())
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension SetDetailsInteractor: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchCards(request: SetDetails.FetchCards.Request())
        updateProgress(request: SetDetails.UpdateProgress.Request())
    }
}
