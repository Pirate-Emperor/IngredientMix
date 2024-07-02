//
//  ProfileTabVC.swift
//  IngredientMix
//

import UIKit
import FirebaseAuth

final class ProfileTabVC: UIViewController {
    
    private var user: UserEntity? {
        didSet {
            setUserNameInCell()
            avatarImageView.image = userManager.getUserAvatar()
            tableView.reloadData()
        }
    }
    
    private let userManager = UserManager.shared
    
    private var userName = "Guest"
    private var addressName: String?
    private var cardName: String?
    
    private let menuItems: [String] = [
        "Account",
        "Delivery Addresses",
        "Payment Methods",
        "Order History",
        "Contact Us"
        // Settings (Language, Theme)
        // Privacy
        // Log Out
    ]
    
    private lazy var avatarImageView: UIImageView = {
        let image = userManager.getUserAvatar()
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.shared.label.withAlphaComponent(0.5)
        imageView.backgroundColor = ColorManager.shared.label.withAlphaComponent(0.1)
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = ColorManager.shared.background
        table.register(ProfileMenuCell.self, forCellReuseIdentifier: ProfileMenuCell.id)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            let defaultAddress = CoreDataManager.shared.getDefaultAddress()
            self.addressName = defaultAddress?.placeName
            self.cardName = CoreDataManager.shared.getPreferredCardName()
            do {
                self.user = try self.userManager.getUserEntity()
            } catch {
                let notification = UserNotification(message: "A user authorization error occurred.", type: .error)
                notification.show(in: self)
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Profile"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorManager.shared.label,
            .font: UIFont.getVariableVersion(of: "Raleway", size: 21, axis: [Constants.fontWeightAxis : 650])
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        
        view.addSubview(avatarImageView)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
            
            tableView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func presentLoginAlert() {
        let alert = UIAlertController(
            title: "Login Required",
            message: "You need to log in to set or change your avatar.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
            self.navigateToLogin()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func navigateToLogin() {
        let vc = LoginVC()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    private func setUserNameInCell() {
        if let user = user {
            if let name = user.displayName, !name.isEmpty {
                userName = name
            } else {
                userName = "User"
            }
        } else {
            userName = "Guest"
        }
    }
    
    // MARK: - Objc methods
    
    @objc
    private func avatarImageViewTapped() {
        if userManager.isUserLoggedIn() {
            presentImagePicker()
        } else {
            presentLoginAlert()
        }
    }
    
}

// MARK: - UITableViewDelegate

extension ProfileTabVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.id, for: indexPath) as! ProfileMenuCell
        
        switch menuItems[indexPath.row] {
        case "Account":
            cell.extraParameter = userName
        case "Delivery Addresses":
            if let address = addressName {
                cell.extraParameter = address
            } else {
                cell.extraParameter = ">"
            }
        case "Payment Methods":
            if let card = cardName {
                cell.extraParameter = card
            } else {
                cell.extraParameter = ">"
            }
        default:
            cell.extraParameter = ""
        }
        
        cell.menuItemName = menuItems[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuItems[indexPath.row] {
        case "Account":
            let vc = AccountVC()
            vc.isUserLoggedIn = userManager.isUserLoggedIn()
            navigationController?.pushViewController(vc, animated: true)
        case "Delivery Addresses":
            navigationController?.pushViewController(DeliveryAddressesVC(), animated: true)
        case "Payment Methods":
            navigationController?.pushViewController(PaymentMethodsVC(), animated: true)
        case "Order History":
            navigationController?.pushViewController(OrderHistoryVC(), animated: true)
        case "Contact Us":
            navigationController?.pushViewController(ContactUsVC(), animated: true)
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.subviews.forEach { subview in
            if subview is SeparatorView {
                subview.removeFromSuperview()
            }
        }

        if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let separatorHeight: CGFloat = 1.0
            let separator = SeparatorView(frame: CGRect(x: 16, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width - 32, height: separatorHeight))
            cell.contentView.addSubview(separator)
        }
    }
}

// MARK: - Picker delegate

extension ProfileTabVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let editedImage = info[.editedImage] as? UIImage else {
            return
        }
        
        Task {
            do {
                try await userManager.uploadUserAvatar(editedImage)
                avatarImageView.image = editedImage
            } catch {
                ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Failed to upload avatar."])
                print("Failed to upload avatar: \(error)")
                
                let notification = UserNotification(message: "There was an error adding an avatar to your account. Please try again later.", type: .warning, interval: 4)
                notification.show(in: self.view)
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

