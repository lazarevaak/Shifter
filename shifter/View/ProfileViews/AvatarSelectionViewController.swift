import UIKit
import CoreData

// MARK: - ViewController
final class AvatarSelectionViewController: UIViewController {

    // MARK: - VIP Components
    var interactor: AvatarSelectionBusinessLogic?
    var router: AvatarSelectionRoutingLogic?

    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = AvatarSelectionLayout.sectionInset
        layout.minimumInteritemSpacing = AvatarSelectionLayout.minimumSpacing
        layout.minimumLineSpacing = AvatarSelectionLayout.minimumSpacing

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(AvatarCell.self, forCellWithReuseIdentifier: "AvatarCell")
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private var selectedIndexPath: IndexPath?
    private var selectedImage: UIImage?
    private var icons: [String] = []

    var onAvatarSelected: ((UIImage) -> Void)?

    // MARK: - Initialization
    init(user: User, context: NSManagedObjectContext) {
        super.init(nibName: nil, bundle: nil)
        setup(user: user, context: context)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(user: User, context: NSManagedObjectContext) {
        let interactor = AvatarSelectionInteractor(user: user, context: context)
        let presenter = AvatarSelectionPresenter()
        let router = AvatarSelectionRouter()

        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupCollectionView()
        interactor?.fetchAvatarIcons(request: AvatarSelection.FetchAvatarIcons.Request())

        NotificationCenter.default.addObserver(self, selector: #selector(updateLocalizedTexts), name: Notification.Name("LanguageDidChange"), object: nil)
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "cancel_button_title".localized,
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorsLayoutConstants.specialTextColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "save_button_title".localized,
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = ColorsLayoutConstants.basicColor

        let cameraButton = UIButton(type: .system)
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        cameraButton.tintColor = ColorsLayoutConstants.specialTextColor

        let galleryButton = UIButton(type: .system)
        galleryButton.setImage(UIImage(systemName: "photo"), for: .normal)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        galleryButton.tintColor = ColorsLayoutConstants.specialTextColor

        let stackView = UIStackView(arrangedSubviews: [cameraButton, galleryButton])
        stackView.axis = .horizontal
        stackView.spacing = AvatarSelectionLayout.cameraGallerySpacing
        navigationItem.titleView = stackView
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        router?.dismiss()
    }

    @objc private func saveButtonTapped() {
        let request = AvatarSelection.SaveAvatar.Request(
            selectedImage: selectedImage,
            selectedIconIndex: selectedIndexPath?.row
        )
        interactor?.saveAvatar(request: request)
    }

    @objc private func cameraButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available on this device")
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }

    @objc private func galleryButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func updateLocalizedTexts() {
        navigationItem.leftBarButtonItem?.title = "cancel_button_title".localized
        navigationItem.rightBarButtonItem?.title = "save_button_title".localized
    }
}

// MARK: - Display Logic
extension AvatarSelectionViewController: AvatarSelectionDisplayLogic {
    func displaySaveAvatar(viewModel: AvatarSelection.SaveAvatar.ViewModel) {
        print(viewModel.displayMessage)
        if viewModel.displayMessage == "avatar_save_message".localized {
            if let image = selectedImage {
                onAvatarSelected?(image)
            } else if let indexPath = selectedIndexPath,
                      let iconName = icons[safe: indexPath.row],
                      let image = UIImage(named: iconName) {
                onAvatarSelected?(image)
            }
            router?.dismiss()
        }
    }

    func displayAvatarIcons(viewModel: AvatarSelection.FetchAvatarIcons.ViewModel) {
        self.icons = viewModel.icons
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension AvatarSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as? AvatarCell else {
            return UICollectionViewCell()
        }
        let iconName = icons[indexPath.row]
        cell.configure(with: iconName)
        let isSelected = (indexPath == selectedIndexPath)
        cell.contentView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        cell.contentView.layer.borderWidth = isSelected ? AvatarSelectionLayout.selectedBorderWidth : 0
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = nil
        selectedIndexPath = indexPath
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = AvatarSelectionLayout.sectionInset.left + AvatarSelectionLayout.sectionInset.right + AvatarSelectionLayout.minimumSpacing * 2
        let width = (collectionView.frame.width - totalSpacing) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension AvatarSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        selectedImage = pickedImage
        selectedIndexPath = nil
        collectionView.reloadData()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - AvatarCell
final class AvatarCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.layer.cornerRadius = AvatarSelectionLayout.cellCornerRadius
        contentView.clipsToBounds = true

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: Layout.imageMultiplier),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: Layout.imageMultiplier)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with iconName: String) {
        imageView.image = UIImage(named: iconName)
    }

    private enum Layout {
        static let imageMultiplier: CGFloat = 0.8
    }
}

// MARK: - Array Safe Access Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
