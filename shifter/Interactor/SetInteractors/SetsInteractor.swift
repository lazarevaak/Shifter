import UIKit
import CoreData

// MARK: - Модели для передачи данных

enum SetsModels {
    struct FetchSetsRequest { }
    
    struct FetchSetsResponse {
        let sets: [CardSet]
    }
    
    struct FetchSetsViewModel {
        let displayedSets: [CardSetViewModel]
    }
    
    struct CardSetViewModel {
        let name: String
        let progressOfSet: Int16
        let id: NSManagedObjectID
    }
    
    struct SearchRequest {
        let query: String
    }
    
    struct SearchResponse {
        let sets: [CardSet]
    }
    
    enum SortOrder {
        case ascending, descending
    }
    struct SortRequest {
        let order: SortOrder
    }
    
    struct DeleteRequest {
        let set: CardSet
    }
}

// MARK: - Протоколы для VIP

protocol SetsBusinessLogic {
    func fetchSets(request: SetsModels.FetchSetsRequest)
    func searchSets(request: SetsModels.SearchRequest)
    func sortSets(request: SetsModels.SortRequest)
    func deleteSet(request: SetsModels.DeleteRequest)
}

protocol SetsPresentationLogic: AnyObject {
    func presentFetchedSets(response: SetsModels.FetchSetsResponse)
    func presentSearchedSets(response: SetsModels.SearchResponse)
    func presentSortedSets(sets: [CardSet])
    func presentDeletedSet()
}

protocol SetsDisplayLogic: AnyObject {
    func displayFetchedSets(viewModel: SetsModels.FetchSetsViewModel)
    func displayError(message: String)
}

// MARK: - Интерактор

final class SetsInteractor: SetsBusinessLogic {
    var presenter: SetsPresentationLogic?
    var currentUser: User
    private var allSets: [CardSet] = []
    
    var availableSets: [CardSet] {
            return allSets
        }
    init(currentUser: User) {
        self.currentUser = currentUser
    }
    
    func fetchSets(request: SetsModels.FetchSetsRequest) {
        if let userSets = currentUser.sets as? Set<CardSet> {
            allSets = Array(userSets)
        } else {
            allSets = []
        }
        let response = SetsModels.FetchSetsResponse(sets: allSets)
        presenter?.presentFetchedSets(response: response)
    }
    
    func searchSets(request: SetsModels.SearchRequest) {
        let query = request.query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered: [CardSet]
        if query.isEmpty {
            filtered = allSets
        } else {
            filtered = allSets.filter { ($0.name ?? "").lowercased().contains(query) }
        }
        let response = SetsModels.SearchResponse(sets: filtered)
        presenter?.presentSearchedSets(response: response)
    }
    
    func sortSets(request: SetsModels.SortRequest) {
        let sorted: [CardSet]
        switch request.order {
        case .ascending:
            sorted = allSets.sorted { ($0.name ?? "") < ($1.name ?? "") }
        case .descending:
            sorted = allSets.sorted { ($0.name ?? "") > ($1.name ?? "") }
        }
        presenter?.presentSortedSets(sets: sorted)
    }
    
    func deleteSet(request: SetsModels.DeleteRequest) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            presenter?.presentDeletedSet()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(request.set)
        do {
            try context.save()
            if let index = allSets.firstIndex(of: request.set) {
                allSets.remove(at: index)
            }
            presenter?.presentDeletedSet()
        } catch {
            presenter?.presentDeletedSet()
        }
    }
}
