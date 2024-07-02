//
//  UserNotification.swift
//  IngredientMix
//

import UIKit

enum NotificationType {
    case info, confirming, warning, error
}

class UserNotification: UIView {
    
    private lazy var blurEffect: UIVisualEffectView = {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect(style: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.effect = blur
        return view
    }()
    
    private var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Raleway", size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var timeInterval: Double = 4
    private var hideTimer: Timer?
    
    init(message: String, image: UIImage? = nil, type: NotificationType, interval: Double = 4) {
        self.timeInterval = interval
        super.init(frame: .zero)
        self.messageLabel.text = message
        
        setupUI(for: type, with: image)
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupUI(for type: NotificationType, with image: UIImage?) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderWidth = 1
        layer.cornerRadius = 24
        layer.masksToBounds = true
        alpha = 0
        
        setColorTheme(for: type)
        
        addSubview(blurEffect)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            blurEffect.topAnchor.constraint(equalTo: topAnchor),
            blurEffect.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            
            addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                imageView.widthAnchor.constraint(equalToConstant: 30),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                messageLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -16)
            ])
        } else {
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        }
    }
    
    private func setColorTheme(for type: NotificationType) {
        switch type {
        case .info:
            backgroundColor = ColorManager.shared.labelGray.withAlphaComponent(0.3)
            layer.borderColor = ColorManager.shared.labelGray.cgColor
        case .confirming:
            backgroundColor = ColorManager.shared.confirmingGreen.withAlphaComponent(0.3)
            layer.borderColor = ColorManager.shared.confirmingGreen.cgColor
        case .warning:
            backgroundColor = ColorManager.shared.warningOrange.withAlphaComponent(0.3)
            layer.borderColor = ColorManager.shared.warningOrange.cgColor
        case .error:
            backgroundColor = ColorManager.shared.warningRed.withAlphaComponent(0.3)
            layer.borderColor = ColorManager.shared.warningRed.cgColor
        }
    }
    
    private func setupGestures() {
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
    }
    
    
    // MARK: - Internal methods
    
    func show(in parentView: UIView) {
        parentView.addSubview(self)
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 32),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -32),
            topAnchor.constraint(equalTo: parentView.topAnchor, constant: -40)
        ])
        
        parentView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 102)
            self.alpha = 1
        }) { _ in
            self.hideTimer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(self.hide), userInfo: nil, repeats: false)
        }
    }

    func show(in viewController: UIViewController) {
        guard let targetView = viewController.navigationController?.view ?? viewController.view else { return }
        show(in: targetView)
    }
    
    func showGlobally() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            show(in: window)
        }
    }
    
    // MARK: - Objc methods
    
    @objc 
    private func hide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, animations: {
            self.transform = .identity
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc 
    private func handleSwipeUp() {
        hideTimer?.invalidate()
        hide()
    }
    
    // MARK: - Static methods
    
    static func show(for error: Error, in vc: UIViewController) {
        let notification: UserNotification
        
        if let networkError = error as? FirebaseManagerError {
            
            switch networkError {
            case .noInternetConnection:
                notification = UserNotification(message: "No internet connection. Please check your connection and try again.", type: .error)
                
            case .invalidData:
                notification = UserNotification(message: "Invalid input data. Please check and try again.", type: .error)
                
            case .parseDataFailed:
                notification = UserNotification(message: "Failed to process data. Please try again later.", type: .error)
                
            case .networkError(let underlyingError):
                notification = UserNotification(message: "Network error. Please try again later.", type: .error)
                print("Network error: \(underlyingError.localizedDescription)")
                
            case .firestoreDataWasNotSaved(let underlyingError):
                notification = UserNotification(message: "Failed to save data. Please try again later.", type: .error)
                print("Firestore save error: \(underlyingError.localizedDescription)")
                
            case .firestoreDataWasNotReceived(let underlyingError):
                notification = UserNotification(message: "Failed to retrieve data. Please try again later.", type: .error)
                print("Firestore receive error: \(underlyingError.localizedDescription)")
                
            case .updateFailed(let underlyingError):
                notification = UserNotification(message: "Failed to update data. Please try again later.", type: .error)
                print("Update error: \(underlyingError.localizedDescription)")
                
            case .downloadImageFailed(let underlyingError):
                notification = UserNotification(message: "Failed to download image. Please try again later.", type: .error)
                print("Image download error: \(underlyingError.localizedDescription)")
                
            case .uploadImageFailed(let underlyingError):
                notification = UserNotification(message: "Failed to upload image. Please try again later.", type: .error)
                print("Image upload error: \(underlyingError.localizedDescription)")
                
            case .authenticationFailed:
                notification = UserNotification(message: "Authentication failed. Please check your credentials and try again.", type: .error)
                
            case .registrationFailed:
                notification = UserNotification(message: "Registration failed. Please check your credentials and try again.", type: .error)
                
            case .userAlreadyExists:
                notification = UserNotification(message: "User already exists. Please use a different email.", type: .warning)
                
            case .userNotFound:
                notification = UserNotification(message: "Authentication problem occurred. Please try again.", type: .warning)
                
            case .promoCodeNotFound:
                notification = UserNotification(message: "Promo code not found. Please check and try again.", type: .warning)
                
            case .promoCodeExpired:
                notification = UserNotification(message: "This promo code has expired.", type: .warning)
                
            case .promoCodeLimitReached:
                notification = UserNotification(message: "This promo code has reached its usage limit.", type: .warning)
            }
            
        } else if let coreDataError = error as? CoreDataManagerError {
            
            switch coreDataError {
            case .fetchError(let underlyingError):
                notification = UserNotification(message: "Failed to retrieve data.", type: .error)
                print("CoreData fetch error: \(underlyingError.localizedDescription)")
                
            case .saveError(let underlyingError):
                notification = UserNotification(message: "Failed to save data.", type: .error)
                print("CoreData save error: \(underlyingError.localizedDescription)")
                
            case .deleteError(let underlyingError):
                notification = UserNotification(message: "Failed to delete data.", type: .error)
                print("CoreData delete error: \(underlyingError.localizedDescription)")
                
            case .itemNotFound:
                notification = UserNotification(message: "Item not found. Please check and try again.", type: .warning)
                
            case .itemAlreadyExists:
                notification = UserNotification(message: "An item with that name already exists.", type: .warning)
            }
            
        } else if let menuManagerError = error as? MenuManagerError {
            
            switch menuManagerError {
            case .failedToCheckMenuRelevance:
                notification = UserNotification(message: "Failed to check if the current menu is up to date.", type: .error)
                
            case .failedToGetLatestMenu:
                notification = UserNotification(message: "Failed to get an up to date version of the menu.", type: .error)
            }
            
        } else if let promoCodeManagerError = error as? PromoCodeManagerError {
            
            switch promoCodeManagerError {
            case .activePromoCodeAlreadyExists:
                notification = UserNotification(message: "You have already activated one promo code. Only one promo code can be used at a time.", type: .error)

            default:
                notification = UserNotification(message: "An internal error occurred while processing a promo code.", type: .error)
            }
            
        } else {
            notification = UserNotification(message: "An unknown error occurred. Please try again later.", type: .error)
            print("Unknown error: \(error)")
        }

        notification.show(in: vc)
    }

}
