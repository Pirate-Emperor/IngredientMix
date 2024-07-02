//
//  DeliveryAddressVC.swift
//  IngredientMix
//

import UIKit

final class DeliveryAddressesVC: UIViewController {

    private var addresses: [AddressEntity] = [] {
        didSet {
            if addresses.isEmpty {
                emptyPageView.isHidden = false
                tableView.isHidden = true
            } else {
                emptyPageView.isHidden = true
                tableView.isHidden = false
            }
        }
    }
    
    private lazy var backButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsBackButton()
        return view
    }()
    
    private lazy var plusButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(plusButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsPlusButton()
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = ColorManager.shared.background
        table.register(DeliveryAddressCell.self, forCellReuseIdentifier: DeliveryAddressCell.id)
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    // MARK: - Empty page view props.
    
    private lazy var emptyPageView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyPageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = ColorManager.shared.label
        label.text = "You have not added a delivery address yet"
        label.font = UIFont(name: "Raleway", size: 22)
        label.numberOfLines = 2
        label.layer.shadowOffset = CGSize(width: 3, height: 3)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        return label
    }()
    
    private lazy var addNewAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.regularButtonHeight / 2
        button.backgroundColor = ColorManager.shared.regularButtonColor
        button.setTitle("Add New Adderess", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(addNewAddressButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(addNewAddressButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
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
        do {
            addresses = try CoreDataManager.shared.fetchAllAddresses()
            tableView.reloadData()
        } catch {
            let notification = UserNotification(message: "An error occurred while loading the data. Please try again later.", type: .error)
            notification.show(in: self)
        }
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Delivery Addresses"
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorManager.shared.label,
            .font: UIFont.getVariableVersion(of: "Raleway", size: 21, axis: [Constants.fontWeightAxis : 650])
        ]
        
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        let backBarButtonItem = UIBarButtonItem(customView: backButtonView)
        let plusBarButtonItem = UIBarButtonItem(customView: plusButtonView)
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.rightBarButtonItem = plusBarButtonItem
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        
        view.addSubview(tableView)
        view.addSubview(emptyPageView)
        
        emptyPageView.addSubview(emptyPageLabel)
        emptyPageView.addSubview(addNewAddressButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyPageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyPageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyPageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyPageView.heightAnchor.constraint(equalToConstant: 200),
            emptyPageLabel.centerXAnchor.constraint(equalTo: emptyPageView.centerXAnchor),
            emptyPageLabel.topAnchor.constraint(equalTo: emptyPageView.topAnchor, constant: 16),
            emptyPageLabel.leadingAnchor.constraint(equalTo: emptyPageView.leadingAnchor, constant: 16),
            emptyPageLabel.trailingAnchor.constraint(equalTo: emptyPageView.trailingAnchor, constant: -16),
            addNewAddressButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            addNewAddressButton.leadingAnchor.constraint(equalTo: emptyPageView.leadingAnchor, constant: 40),
            addNewAddressButton.trailingAnchor.constraint(equalTo: emptyPageView.trailingAnchor, constant: -40),
            addNewAddressButton.bottomAnchor.constraint(equalTo: emptyPageView.bottomAnchor, constant: -16),
        ])
    }
    
    private func deleteAddress(at indexPath: IndexPath) {
        guard let placeName = addresses[indexPath.row].placeName else { return }
        do {
            try CoreDataManager.shared.deleteAddress(by: placeName)
            addresses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            let notification = UserNotification(message: "An error occurred while deleting the data. Please try again later.", type: .error)
            notification.show(in: self)
        }
    }
    
    private func setAddressAsDefaultInLocal(at indexPath: IndexPath) {
        for i in 0...addresses.count-1 {
            addresses[i].isDefaultAddress = (i == indexPath.row)
        }
    }
    
    // MARK: - Objc methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func plusButtonTapped() {
        navigationController?.pushViewController(AddressVC(), animated: true)
    }
    
    @objc
    private func addNewAddressButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.addNewAddressButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func addNewAddressButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.addNewAddressButton.transform = CGAffineTransform.identity
        }, completion: nil)
        plusButtonTapped()
    }
    
}

// MARK: - Table view methods

extension DeliveryAddressesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeliveryAddressCell.id, for: indexPath) as! DeliveryAddressCell
        
        cell.placeName = addresses[indexPath.row].placeName
        cell.isDefaultAdress = addresses[indexPath.row].isDefaultAddress
        
        cell.goToAddressVCHandler = { [weak self] in
            guard let addressEntity = self?.addresses[indexPath.row] else { return }
            let vc = AddressVC()
            vc.configureWithExisting(addressEntity)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !addresses[indexPath.row].isDefaultAddress {
            guard let placeName = addresses[indexPath.row].placeName else { return }
            do {
                try CoreDataManager.shared.setAddressAsDefault(by: placeName)
                setAddressAsDefaultInLocal(at: indexPath)
                tableView.reloadData()
                navigationController?.popViewController(animated: true)
            } catch {
                let notification = UserNotification(message: "An error occurred during data processing. Please try again later.", type: .error)
                notification.show(in: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            self?.deleteAddress(at: indexPath)
            completionHandler(true)
        }
        
        if let trashImage = UIImage(systemName: "trash") {
            let size = CGSize(width: 26, height: 30)
            let renderer = UIGraphicsImageRenderer(size: size)
            let tintedImage = renderer.image { context in
                trashImage.withTintColor(ColorManager.shared.warningRed).draw(in: CGRect(origin: .zero, size: size))
            }
            deleteAction.image = tintedImage
        }
        
        deleteAction.backgroundColor = ColorManager.shared.background

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
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

extension DeliveryAddressesVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
