//
//  UserNameVC.swift
//  IngredientMix
//

import UIKit

final class SetUsernameVC: UIViewController {
        
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
        label.text = "Enter your new username"
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Username"
        return label
    }()
    
    private lazy var usernameField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
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
        
        do {
            let user = try UserManager.shared.getUserEntity()
            usernameField.text = user?.displayName
        } catch {
            let notification = UserNotification(message: "A user authorization error occurred.", type: .error)
            notification.show(in: self)
        }
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Change Username"
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
        view.addSubview(usernameLabel)
        view.addSubview(usernameField)
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            usernameLabel.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 32),
            usernameLabel.leadingAnchor.constraint(equalTo: usernameField.leadingAnchor, constant: 16),
            usernameField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            usernameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            usernameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            usernameField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            saveButton.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 80),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
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
        
        if let username = usernameField.text {
            Task {
                do {
                    try await UserManager.shared.setUserName(username)
                    navigationController?.popViewController(animated: true)
                } catch {
                    ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to change user display name."])
                    UserNotification.show(for: error, in: self)
                }
            }
        }
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension SetUsernameVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - UITextFieldDelegate

extension SetUsernameVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
