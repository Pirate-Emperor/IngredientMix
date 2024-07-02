//
//  ChangePasswordVC.swift
//  IngredientMix
//

import UIKit

final class ChangePasswordVC: UIViewController {
        
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
        label.text = "Enter your current password and your new password"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var currentPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Current Password"
        return label
    }()
    
    private lazy var currentPasswordField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.associatedLabel = currentPasswordLabel
        field.autocapitalizationType = .none
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        field.delegate = self
        return field
    }()
    
    private lazy var newPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "New Password"
        return label
    }()
    
    private lazy var newPasswordField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.associatedLabel = newPasswordLabel
        field.autocapitalizationType = .none
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        field.delegate = self
        return field
    }()
    
    private lazy var confirmNewPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Confirm Password"
        return label
    }()
    
    private lazy var confirmNewPasswordField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.associatedLabel = confirmNewPasswordLabel
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
        title = "Change Password"
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
        view.addSubview(currentPasswordLabel)
        view.addSubview(currentPasswordField)
        view.addSubview(newPasswordLabel)
        view.addSubview(newPasswordField)
        view.addSubview(confirmNewPasswordLabel)
        view.addSubview(confirmNewPasswordField)
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            currentPasswordLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 32),
            currentPasswordLabel.leadingAnchor.constraint(equalTo: currentPasswordField.leadingAnchor, constant: 16),
            currentPasswordField.topAnchor.constraint(equalTo: currentPasswordLabel.bottomAnchor, constant: 8),
            currentPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            currentPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            currentPasswordField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            newPasswordLabel.topAnchor.constraint(equalTo: currentPasswordField.bottomAnchor, constant: 12),
            newPasswordLabel.leadingAnchor.constraint(equalTo: newPasswordField.leadingAnchor, constant: 16),
            newPasswordField.topAnchor.constraint(equalTo: newPasswordLabel.bottomAnchor, constant: 8),
            newPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            newPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            newPasswordField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            confirmNewPasswordLabel.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 12),
            confirmNewPasswordLabel.leadingAnchor.constraint(equalTo: confirmNewPasswordField.leadingAnchor, constant: 16),
            confirmNewPasswordField.topAnchor.constraint(equalTo: confirmNewPasswordLabel.bottomAnchor, constant: 8),
            confirmNewPasswordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            confirmNewPasswordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            confirmNewPasswordField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            saveButton.topAnchor.constraint(equalTo: confirmNewPasswordField.bottomAnchor, constant: 80),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func isFormValid() -> Bool {
        var isValid = true
        let minimumPasswordLength = 6

        if currentPasswordField.text?.count ?? 0 < minimumPasswordLength {
            currentPasswordField.isInWarning = true
            isValid = false
        }
        
        if newPasswordField.text?.count ?? 0 < minimumPasswordLength {
            newPasswordField.isInWarning = true
            isValid = false
        }
        
        if confirmNewPasswordField.text?.count ?? 0 < minimumPasswordLength {
            confirmNewPasswordField.isInWarning = true
            isValid = false
        }
        
        if newPasswordField.text != confirmNewPasswordField.text {
            newPasswordField.isInWarning = true
            confirmNewPasswordField.isInWarning = true
            isValid = false
        }
        
        return isValid
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
        
        if isFormValid() {
            guard let olpPass = currentPasswordField.text, let newPass = newPasswordField.text else { return }
            Task {
                do {
                    try await UserManager.shared.updatePassword(currentPassword: olpPass, to: newPass)
                } catch {
                    ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to change user password."])
                    UserNotification.show(for: error, in: self)
                }
            }
        } else {
            let notification = UserNotification(message: "Please fill in all fields.", type: .warning, interval: 3)
            notification.show(in: self)
        }
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ChangePasswordVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - UITextFieldDelegate

extension ChangePasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let field = textField as? TextField {
            field.isInWarning = false
        }
    }
    
}
