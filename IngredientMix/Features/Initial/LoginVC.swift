//
//  LoginVC.swift
//  IngredientMix
//

import UIKit
import FirebaseAuth

final class LoginVC: UIViewController {
    
    private lazy var isOpenedModally = navigationController?.presentingViewController?.presentedViewController == navigationController
    
    private lazy var backButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsBackButton()
        return view
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
        field.autocapitalizationType = .none
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
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.regularButtonHeight / 2
        button.backgroundColor = ColorManager.shared.regularButtonColor
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(loginButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(loginButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    private lazy var createAccountView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dontHaveAccountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Don't have an account?"
        return label
    }()
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create account", for: .normal)
        button.setTitleColor(ColorManager.shared.login_secondaryButtonColor, for: .normal)
        button.setTitleColor(ColorManager.shared.login_secondaryButtonColor.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var continueAsGuestView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var orContinueAsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Or continue as a"
        return label
    }()
    
    private lazy var guestButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("guest", for: .normal)
        button.setTitleColor(ColorManager.shared.login_secondaryButtonColor, for: .normal)
        button.setTitleColor(ColorManager.shared.login_secondaryButtonColor.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(guestButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        if isOpenedModally {
            prepareForAnimations()
        } else {
            setupNavBar()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isOpenedModally {
            startAnimations()
        }
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Log In"
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
        
        view.addSubview(emailLabel)
        view.addSubview(emailField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(createAccountView)
        view.addSubview(continueAsGuestView)
        
        createAccountView.addSubview(dontHaveAccountLabel)
        createAccountView.addSubview(createAccountButton)
        continueAsGuestView.addSubview(orContinueAsLabel)
        continueAsGuestView.addSubview(guestButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 80),
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
            
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 80),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            
            createAccountView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            createAccountView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountView.leadingAnchor.constraint(equalTo: dontHaveAccountLabel.leadingAnchor),
            createAccountView.trailingAnchor.constraint(equalTo: createAccountButton.trailingAnchor),
            createAccountView.bottomAnchor.constraint(equalTo: createAccountButton.bottomAnchor),
            createAccountButton.topAnchor.constraint(equalTo: createAccountView.topAnchor),
            createAccountButton.leadingAnchor.constraint(equalTo: dontHaveAccountLabel.trailingAnchor, constant: 4),
            dontHaveAccountLabel.centerYAnchor.constraint(equalTo: createAccountButton.centerYAnchor),
            
            continueAsGuestView.topAnchor.constraint(equalTo: createAccountView.bottomAnchor, constant: 8),
            continueAsGuestView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueAsGuestView.leadingAnchor.constraint(equalTo: orContinueAsLabel.leadingAnchor),
            continueAsGuestView.trailingAnchor.constraint(equalTo: guestButton.trailingAnchor),
            continueAsGuestView.bottomAnchor.constraint(equalTo: guestButton.bottomAnchor),
            guestButton.topAnchor.constraint(equalTo: continueAsGuestView.topAnchor),
            guestButton.leadingAnchor.constraint(equalTo: orContinueAsLabel.trailingAnchor, constant: 4),
            orContinueAsLabel.centerYAnchor.constraint(equalTo: guestButton.centerYAnchor)
        ])
    }
    
    private func prepareForAnimations() {
        [emailLabel, emailField, passwordLabel, passwordField, loginButton, createAccountView, continueAsGuestView].forEach {
            $0.transform = CGAffineTransform(translationX: 0, y: 300)
            $0.alpha = 0.0
        }
    }
    
    private func startAnimations() {
        let labels = [emailLabel, passwordLabel]
        for (index, label) in labels.enumerated() {
            UIView.animate(
                withDuration: 0.7,
                delay: 0.1 * Double(index),
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.5,
                animations: {
                    label.transform = .identity
                    label.alpha = 1.0
                }
            )
        }
        
        let elements = [emailField, passwordField, loginButton, createAccountView, continueAsGuestView]
        for (index, element) in elements.enumerated() {
            UIView.animate(
                withDuration: 0.7,
                delay: 0.1 * Double(index),
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.5,
                animations: {
                    element.transform = .identity
                    element.alpha = 1.0
                },
                completion: { _ in
                    self.emailField.becomeFirstResponder()
                }
            )
        }
    }
    
    private func authenticateUser() {
        if isFormValid() {
            guard let email = emailField.text, let password = passwordField.text else { return }
            
            Task {
                do {
                    try await UserManager.shared.authenticateUser(email: email, password: password)
                    if isOpenedModally {
                        // need handler
                    } else {
                        navigationController?.popViewController(animated: true)
                    }
                } catch {
                    ErrorLogger.shared.logError(error, additionalInfo: ["Action": "Authentication attempt", "Email": email, "Pass": password])
                    UserNotification.show(for: error, in: self)
                }
            }
        } else {
            let notification = UserNotification(message: "Please fill in all fields.", type: .warning, interval: 3)
            notification.show(in: self.view)
        }
    }
    
    private func isFormValid() -> Bool {
        var isValid = true
        
        if emailField.text?.isEmpty ?? true {
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
    
    // MARK: - Objc methods
    
    @objc
    private func loginButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.loginButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func loginButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.loginButton.transform = CGAffineTransform.identity
        }, completion: nil)
        
        authenticateUser()
    }
    
    @objc
    private func createAccountButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func guestButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }

}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
            authenticateUser()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let field = textField as? TextField {
            field.isInWarning = false
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension LoginVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
