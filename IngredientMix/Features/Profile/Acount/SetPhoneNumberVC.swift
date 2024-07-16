//
//  SetPhoneNumberVC.swift
//  IngredientMix
//

import UIKit

final class SetPhoneNumberVC: UIViewController {
        
    private lazy var backButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsBackButton()
        return view
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Raleway", size: 14)
        label.text = "Enter your phone number"
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Phone Number"
        return label
    }()
    
    private lazy var phoneNumberField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.associatedLabel = phoneNumberLabel
        field.keyboardType = .phonePad
        field.returnKeyType = .done
        field.delegate = self
        return field
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.regularButtonHeight / 2
        button.backgroundColor = ColorManager.shared.regularButtonColor
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(saveButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(saveButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()

    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Change Phone Number"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorManager.shared.label,
            .font: UIFont.getVariableVersion(of: "Raleway", size: 21, axis: [Constants.fontWeightAxis : 650])
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        let backBarButtonItem = UIBarButtonItem(customView: backButtonView)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        view.addSubview(instructionLabel)
        view.addSubview(phoneNumberLabel)
        view.addSubview(phoneNumberField)
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            phoneNumberLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 32),
            phoneNumberLabel.leadingAnchor.constraint(equalTo: phoneNumberField.leadingAnchor, constant: 16),
            phoneNumberField.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 8),
            phoneNumberField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            phoneNumberField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            phoneNumberField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            saveButton.topAnchor.constraint(equalTo: phoneNumberField.bottomAnchor, constant: 80),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func validatePhoneNumber() {
        guard let phoneNumber = phoneNumberField.text, !phoneNumber.isEmpty else {
            phoneNumberField.isInWarning = true
            return
        }
        
        let phoneRegex = "^[+][0-9]{10,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        if phoneTest.evaluate(with: phoneNumber) {
            do {
                try CoreDataManager.shared.savePhoneNumber(phoneNumber)
                phoneNumberField.isInWarning = false
            } catch {
                let notification = UserNotification(message: "An error occurred while saving data. Please try again later.", type: .error, interval: 5)
                notification.show(in: self)
            }
        } else {
            phoneNumberField.isInWarning = true
        }
    }
    
    // MARK: - Objc methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func saveButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func saveButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.saveButton.transform = CGAffineTransform.identity
        }, completion: nil)
        
        validatePhoneNumber()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension SetPhoneNumberVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - UITextFieldDelegate

extension SetPhoneNumberVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        validatePhoneNumber()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let field = textField as? TextField {
            field.isInWarning = false
            
            if let text = field.text, text.isEmpty {
                field.text = "+"
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNumberField {
            if range.location == 0 && range.length == 1 && string.isEmpty {
                return false
            }
        }
        return true
    }
    
}

