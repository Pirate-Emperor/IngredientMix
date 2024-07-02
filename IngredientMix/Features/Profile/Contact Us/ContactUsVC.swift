//
//  ContactUsVC.swift
//  IngredientMix
//

import UIKit

final class ContactUsVC: UIViewController {
        
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
        label.text = "Send us your message and we will get back to you"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = ColorManager.shared.label
        textView.backgroundColor = ColorManager.shared.regularFieldColor
        textView.tintColor = ColorManager.shared.orange
        textView.layer.cornerRadius = 24
        textView.layer.borderColor = ColorManager.shared.regularFieldBorderColor
        textView.layer.borderWidth = 1
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.regularButtonHeight / 2
        button.backgroundColor = ColorManager.shared.regularButtonColor
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(sendButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(sendButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageTextView.becomeFirstResponder()
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Contact Us"
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
        view.addSubview(messageTextView)
        view.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 40),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            messageTextView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 40),
            messageTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            messageTextView.heightAnchor.constraint(equalToConstant: 200),
            
            sendButton.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Objc methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func sendButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.sendButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func sendButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.sendButton.transform = CGAffineTransform.identity
        }, completion: nil)
        
        let message = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
                
        if message.isEmpty {
            let notification = UserNotification(message: """
                Empty Message
                Please enter a message before sending
            """, type: .warning, interval: 3)
            notification.show(in: self)
        } else {
            
            Task {
                do {
                    try await FirebaseManager.shared.sendFeedback(message: message)
                    
                    let notification = UserNotification(message: """
                        Message Sent
                        Thank you for your feedback
                    """, type: .confirming, interval: 3)
                    notification.show(in: self)

                    messageTextView.text = ""
                } catch {
                    ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to send a feedback message."])
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

extension ContactUsVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
