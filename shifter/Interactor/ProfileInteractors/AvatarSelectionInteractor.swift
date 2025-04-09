import UIKit
import CoreData

// MARK: - Models

enum AvatarSelection {
    
    // MARK: Save Avatar Models
    enum SaveAvatar {
        struct Request {
            let selectedImage: UIImage?
            let selectedIconIndex: Int?
        }
        
        struct Response {
            let success: Bool
            let message: String?
        }
        
        struct ViewModel {
            let displayMessage: String
        }
    }
    
    // MARK: Fetch Avatar Icons Models
    enum FetchAvatarIcons {
        struct Request { }
        
        struct Response {
            let icons: [String]
        }
        
        struct ViewModel {
            let icons: [String]
        }
    }
}

// MARK: - Protocols

// MARK: Business Logic
protocol AvatarSelectionBusinessLogic {
    func saveAvatar(request: AvatarSelection.SaveAvatar.Request)
    func fetchAvatarIcons(request: AvatarSelection.FetchAvatarIcons.Request)
}

// MARK: Presentation Logic
protocol AvatarSelectionPresentationLogic: AnyObject {
    func presentSaveAvatar(response: AvatarSelection.SaveAvatar.Response)
    func presentAvatarIcons(response: AvatarSelection.FetchAvatarIcons.Response)
}

// MARK: Routing Logic
protocol AvatarSelectionRoutingLogic {
    func dismiss()
}

// MARK: Display Logic
protocol AvatarSelectionDisplayLogic: AnyObject {
    func displaySaveAvatar(viewModel: AvatarSelection.SaveAvatar.ViewModel)
    func displayAvatarIcons(viewModel: AvatarSelection.FetchAvatarIcons.ViewModel)
}

// MARK: - Interactor

final class AvatarSelectionInteractor: AvatarSelectionBusinessLogic {
    
    // MARK: - Properties
    var presenter: AvatarSelectionPresentationLogic?
    private let user: User
    private let context: NSManagedObjectContext
    
    // MARK: - Init
    init(user: User, context: NSManagedObjectContext) {
        self.user = user
        self.context = context
    }
    
    // MARK: - Business Logic
    func saveAvatar(request: AvatarSelection.SaveAvatar.Request) {
        var selectedImage: UIImage?
        if let index = request.selectedIconIndex {
            let iconName = AvatarSelectionConstants.avatarIcons[index]
            selectedImage = UIImage(named: iconName)
        }
        if let image = request.selectedImage {
            selectedImage = image
        }
        
        guard let finalImage = selectedImage,
              let data = finalImage.jpegData(compressionQuality: 0.8) else {
            let response = AvatarSelection.SaveAvatar.Response(success: false, message: "choose_avatar_message".localized)
            presenter?.presentSaveAvatar(response: response)
            return
        }
        
        user.avatarData = data
        do {
            try context.save()
            let response = AvatarSelection.SaveAvatar.Response(success: true, message: "avatar_save_message".localized)
            presenter?.presentSaveAvatar(response: response)
        } catch {
            let response = AvatarSelection.SaveAvatar.Response(success: false, message: "avatar_save_error".localized + "\(error)")
            presenter?.presentSaveAvatar(response: response)
        }
    }
    
    func fetchAvatarIcons(request: AvatarSelection.FetchAvatarIcons.Request) {
        let response = AvatarSelection.FetchAvatarIcons.Response(icons: AvatarSelectionConstants.avatarIcons)
        presenter?.presentAvatarIcons(response: response)
    }
}
