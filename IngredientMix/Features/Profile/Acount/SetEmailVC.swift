//
//  SetEmailVC.swift
//  IngredientMix
//

import UIKit

final class SetEmailVC: UIViewController {
        
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
        label.text = """
            Enter your new email and password to confirm the action
            
            You will receive an email to verify your new email address
            """
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Email"
        return label
    }()
    
    private lazy var emailField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.associatedLabel = emailLabel
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.delegate = self
        return field
    }()
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Password"
        return label
    }()
    
    private lazy var passwordField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.associatedLabel = passwordLabel
        field.autocapitalizationType = .none
        field.isSecureTextEntry = true
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
        title = "Change Email"
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
        view.addSubview(emailLabel)
        view.addSubview(emailField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordField)
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            emailLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 32),
            emailLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor, constant: 16),
            emailField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            passwordLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordLabel.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor, constant: 16),
            passwordField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 8),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            saveButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 80),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func updateEmail() {
        if isFormValid() {
            guard let email = emailField.text,
                  let password = passwordField.text else { return }
            
            Task {
                do {
                    try await UserManager.shared.updateEmail(to: email, withPassword: password)
                    
                    let notification = UserNotification(message: "A verification message has been sent to your new email. Please confirm your new email.", type: .confirming, interval: 5)
                    notification.show(in: self)
                    
                    navigationController?.popViewController(animated: true)
                } catch {
                    ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to update user email."])
                    UserNotification.show(for: error, in: self)
                }
            }
        } else {
            let notification = UserNotification(message: "Please fill in all fields.", type: .warning, interval: 3)
            notification.show(in: self)
        }
    }
    
    private func isFormValid() -> Bool {
        var isValid = true
        
        if emailField.text?.isEmpty ?? true {
            emailField.isInWarning = true
            isValid = false
        } else if !isValidEmail(emailField.text!) {
            emailField.isInWarning = true
            isValid = false
        } else {
            emailField.isInWarning = false
        }
        
        if passwordField.text?.isEmpty ?? true {
            passwordField.isInWarning = true
            isValid = false
        } else {
            passwordField.isInWarning = false
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
        
        updateEmail()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension SetEmailVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - UITextFieldDelegate

extension SetEmailVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let field = textField as? TextField {
            field.isInWarning = false
        }
    }
    
}
