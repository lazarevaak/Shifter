import UIKit

// MARK: - Константы для SetActViewController
enum SetActConstants {
    static let backButtonTopMargin: CGFloat = 10
    static let backButtonLeadingMargin: CGFloat = 16
    static let titleLabelTopMargin: CGFloat = 10
    static let termsLabelTopMargin: CGFloat = 30
    static let termsPickerTopMargin: CGFloat = 10
    static let definitionsLabelTopMargin: CGFloat = 20
    static let definitionsPickerTopMargin: CGFloat = 10
    static let horizontalInset: CGFloat = 20
    
    static let titleFontSize: CGFloat = 24
    static let labelFontSize: CGFloat = 18
}

class SetActViewController: UIViewController {
    
    private let languages = ["English", "Русский"]
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.left")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(ColorsLayoutConstants.basicColor)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.boldSystemFont(ofSize: SetActConstants.titleFontSize)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "Language of terms"
        label.font = UIFont.systemFont(ofSize: SetActConstants.labelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let definitionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Language of definitions"
        label.font = UIFont.systemFont(ofSize: SetActConstants.labelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let termsPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private let definitionsPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorsLayoutConstants.buttonTextbackgroundColor

        termsPicker.delegate = self
        termsPicker.dataSource = self
        definitionsPicker.delegate = self
        definitionsPicker.dataSource = self

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        setupLayout()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(termsLabel)
        view.addSubview(termsPicker)
        view.addSubview(definitionsLabel)
        view.addSubview(definitionsPicker)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: SetActConstants.backButtonTopMargin),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: SetActConstants.backButtonLeadingMargin),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: SetActConstants.titleLabelTopMargin),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            termsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                            constant: SetActConstants.termsLabelTopMargin),
            termsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: SetActConstants.horizontalInset),
            
            termsPicker.topAnchor.constraint(equalTo: termsLabel.bottomAnchor,
                                             constant: SetActConstants.termsPickerTopMargin),
            termsPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: SetActConstants.horizontalInset),
            termsPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -SetActConstants.horizontalInset),
            
            definitionsLabel.topAnchor.constraint(equalTo: termsPicker.bottomAnchor,
                                                  constant: SetActConstants.definitionsLabelTopMargin),
            definitionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: SetActConstants.horizontalInset),
            
            definitionsPicker.topAnchor.constraint(equalTo: definitionsLabel.bottomAnchor,
                                                   constant: SetActConstants.definitionsPickerTopMargin),
            definitionsPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                       constant: SetActConstants.horizontalInset),
            definitionsPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: -SetActConstants.horizontalInset),
        ])
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension SetActViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedLanguage = languages[row]
        
        if pickerView == termsPicker {
            print("Selected language for terms: \(selectedLanguage)")
        } else if pickerView == definitionsPicker {
            print("Selected language for definitions: \(selectedLanguage)")
        }
    }
}
