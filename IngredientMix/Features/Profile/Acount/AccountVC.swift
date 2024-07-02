//
//  AccountVC.swift
//  IngredientMix
//

import UIKit

final class AccountVC: UIViewController {
    
    var isUserLoggedIn = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let loggedUserMenuItems: [String] = [
        "Username",
        "Email",
        "Phone Number",
        "Change Password",
        "Log Out"
    ]
    
    private let guestMenuItems: [String] = [
        "Log In",
        "Create Account"
    ]
    
    private lazy var backButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsBackButton()
        return view
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
        isUserLoggedIn = UserManager.shared.isUserLoggedIn()
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Account"
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
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func presentLogOutAlert() {
        let alert = UIAlertController(
            title: nil,
            message: "Do you really want to log out of your account?",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            do {
                try UserManager.shared.logoutUser()
                self.isUserLoggedIn = false
            } catch {
                ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to logout."])
                print("Error when trying to logout: \(error)")
                
                UserNotification.show(for: error, in: self)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Objc methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - UITableViewDelegate

extension AccountVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isUserLoggedIn {
            loggedUserMenuItems.count
        } else {
            guestMenuItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.id, for: indexPath) as! ProfileMenuCell
        cell.selectionStyle = .none
        
        if isUserLoggedIn {
            cell.menuItemName = loggedUserMenuItems[indexPath.row]
        } else {
            cell.menuItemName = guestMenuItems[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isUserLoggedIn {
            switch loggedUserMenuItems[indexPath.row] {
            case "Username":
                navigationController?.pushViewController(SetUsernameVC(), animated: true)
            case "Email":
                navigationController?.pushViewController(SetEmailVC(), animated: true)
            case "Phone Number":
                navigationController?.pushViewController(SetPhoneNumberVC(), animated: true)
            case "Change Password":
                navigationController?.pushViewController(ChangePasswordVC(), animated: true)
            case "Log Out":
                presentLogOutAlert()
            default: return
            }
        } else {
            switch guestMenuItems[indexPath.row] {
            case "Log In":
                navigationController?.pushViewController(LoginVC(), animated: true)
            case "Create Account":
                navigationController?.pushViewController(CreateAccountVC(), animated: true)
            default: return
            }
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

// MARK: - UIGestureRecognizerDelegate

extension AccountVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
