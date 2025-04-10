import UIKit

final class EditLanguageViewController: UIViewController, EditLanguageDisplayLogic {
    
    weak var delegate: EditLanguageDelegate?
    
    var interactor: EditLanguageBusinessLogic?
    var router: EditLanguageRoutingLogic?
    
    private var currentLanguage: String
    private let languages: [String: String]
    
    private var languageCodes: [String] {
        return Array(languages.keys).sorted()
    }
    
    // MARK: - UI Elements
    private lazy var pickerView: UIPickerView = {
        let pv = UIPickerView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("save_button_title".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ColorsLayoutConstants.basicColor
        button.layer.cornerRadius = 8
        button.setTitleColor(ColorsLayoutConstants.buttonTextColor, for: .normal)
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    init(currentLanguage: String, languages: [String: String]? = nil) {
        self.currentLanguage = currentLanguage
        self.languages = languages ?? ["en": "English", "ru": "Русский"]
        super.init(nibName: nil, bundle: nil)
        setupVIP()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupVIP() {
        let interactor = EditLanguageInteractor()
        let presenter = EditLanguagePresenter()
        let router = EditLanguageRouter()
        self.interactor = interactor
        self.router = router
        interactor.presenter = presenter
        presenter.viewController = self
        router.viewController = self
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.backgroundColor
        setupLayout()
        
        if let index = languageCodes.firstIndex(of: currentLanguage) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateLocalizedTexts),
                                               name: Notification.Name("LanguageDidChange"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupLayout() {
        view.addSubview(pickerView)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: SizeLayoutConstants.editConstaintSize),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 150),
            
            saveButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: SizeLayoutConstants.editConstaintSize),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SizeLayoutConstants.editConstaintSize),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -SizeLayoutConstants.editConstaintSize),
            saveButton.heightAnchor.constraint(equalToConstant: SizeLayoutConstants.editHeightAnchorSize)
        ])
    }
    
    @objc private func saveTapped() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let newLanguage = languageCodes[selectedRow]
        let request = EditLanguageModels.UpdateLanguage.Request(newLanguage: newLanguage)
        interactor?.updateLanguage(request: request)
        
        // Обновляем язык через LocalizationManager
        LocalizationManager.shared.updateLanguage(to: newLanguage)
    }
    
    // MARK: - EditLanguageDisplayLogic
    func displayUpdateLanguage(viewModel: EditLanguageModels.UpdateLanguage.ViewModel) {
        if viewModel.success {
            delegate?.didUpdateLanguage(languageCodes[pickerView.selectedRow(inComponent: 0)])
            router?.routeToPreviousScreen()
        } else {
            let alert = UIAlertController(title: "error_alert_title".localized,
                                          message: viewModel.message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
    }
    
    // Обновление UI при смене языка
    @objc func updateLocalizedTexts() {
        saveButton.setTitle("save_button_title".localized, for: .normal)
        // При необходимости обновляем другие элементы
    }
}

extension EditLanguageViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageCodes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let code = languageCodes[row]
        return languages[code] ?? code
    }
}
