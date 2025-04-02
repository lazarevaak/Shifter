import UIKit
import CoreData


// MARK: - AvatarSelectionViewController
final class AvatarSelectionViewController: UIViewController {
    
    // MARK: - Свойство Core Data

    private let user: User
    
    /// Контекст Core Data
    private let context = (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer.viewContext
    
    // MARK: - Публичное свойство для обратного вызова
    /// Передаёт выбранное изображение обратно (для обновления UI в вызывающем контроллере)
    var onAvatarSelected: ((UIImage) -> Void)?
    
    /// Храним выбранное изображение (из камеры, галереи или выбранной иконки)
    private var selectedImage: UIImage?
    
    // Массив имён иконок. Добавлены записи "redAvatar" и "grayAvatar" для специальных вариантов.
    private let avatarIcons: [String] = [
        "person.circle",
        "person.circle.fill",
        "redAvatar",
        "grayAvatar"
    ]
    
    private var selectedIndexPath: IndexPath?
    
    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(AvatarCell.self, forCellWithReuseIdentifier: "AvatarCell")
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // MARK: - Инициализатор
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не используется")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        let cancelItem = UIBarButtonItem(
            title: "Отменить",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        cancelItem.tintColor = .gray
        navigationItem.leftBarButtonItem = cancelItem
        
        let saveItem = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        saveItem.tintColor = ColorsLayoutConstants.basicColor
        navigationItem.rightBarButtonItem = saveItem
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        cameraButton.tintColor = .gray  
        
        let galleryButton = UIButton(type: .system)
        galleryButton.setImage(UIImage(systemName: "photo"), for: .normal)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        galleryButton.tintColor = .gray
        
        let stackView = UIStackView(arrangedSubviews: [cameraButton, galleryButton])
        stackView.axis = .horizontal
        stackView.spacing = 24
        
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
    
    // MARK: - Действия
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        if let indexPath = selectedIndexPath {
            let iconName = avatarIcons[indexPath.row]
            selectedImage = imageForIcon(named: iconName)
        }
        
        guard let finalImage = selectedImage else {
            print("Выберите аватарку или сделайте фото")
            return
        }
        
        if let data = finalImage.jpegData(compressionQuality: 0.8) {
            user.avatarData = data
            do {
                try context.save()
                print("Аватар успешно сохранён для пользователя с email: \(user.email ?? "nil")")
            } catch {
                print("Ошибка сохранения аватара: \(error)")
            }
        }
        
        onAvatarSelected?(finalImage)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cameraButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Камера недоступна на этом устройстве/эмуляторе")
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func galleryButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    private func imageForIcon(named iconName: String) -> UIImage? {
        if iconName == "redAvatar" {
            let image = UIImage(systemName: "person.circle.fill")
            return image?.withTintColor(ColorsLayoutConstants.basicColor, renderingMode: .alwaysOriginal)
        } else if iconName == "grayAvatar" {
            let image = UIImage(systemName: "person.circle.fill")
            return image?.withTintColor(ColorsLayoutConstants.additionalColor, renderingMode: .alwaysOriginal)
        } else {
            return UIImage(systemName: iconName)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension AvatarSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AvatarCell",
                for: indexPath
        ) as? AvatarCell else {
            return UICollectionViewCell()
        }
        let iconName = avatarIcons[indexPath.row]
        cell.configure(with: iconName)
        
        let isSelected = (indexPath == selectedIndexPath)
        cell.contentView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        cell.contentView.layer.borderWidth = isSelected ? 2 : 0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = nil
        selectedIndexPath = indexPath
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 16 * 2 + 8 * 2
        let width = (collectionView.frame.width - totalSpacing) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension AvatarSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let pickedImage = info[.originalImage] as? UIImage else { return }
        
        selectedImage = pickedImage
        selectedIndexPath = nil
        collectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - AvatarCell
final class AvatarCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не используется")
    }
    
    func configure(with iconName: String) {
        if iconName == "redAvatar" {
            let image = UIImage(systemName: "person.circle.fill")
            imageView.image = image?.withTintColor(ColorsLayoutConstants.basicColor, renderingMode: .alwaysOriginal)
        } else if iconName == "grayAvatar" {
            let image = UIImage(systemName: "person.circle.fill")
            imageView.image = image?.withTintColor(ColorsLayoutConstants.additionalColor, renderingMode: .alwaysOriginal)
        } else {
            imageView.image = UIImage(systemName: iconName)
            imageView.tintColor = .label
        }
    }
}
