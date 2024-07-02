//
//  OrderHistoryVC.swift
//  IngredientMix
//

import UIKit

final class OrderHistoryVC: UIViewController {
    
    private var orders: [OrderEntity]!
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm"
        return formatter
    }()
    
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
        table.register(OrderHistoryTableCell.self, forCellReuseIdentifier: OrderHistoryTableCell.id)
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    private lazy var orderHistoryIsEmpty: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = ColorManager.shared.label
        label.text = "Your order history is empty"
        label.font = UIFont(name: "Raleway", size: 22)
        label.numberOfLines = 1
        label.layer.shadowOffset = CGSize(width: 3, height: 3)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        return label
    }()
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
        
        do {
            orders = try CoreDataManager.shared.fetchOrders()
        } catch {
            ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to load order history from storage."])
            
            let notification = UserNotification(message: "An error occurred while loading the data. Please try again later.", type: .error, interval: 5)
            notification.show(in: self)
        }
        
        orderHistoryIsEmpty.isHidden = !orders.isEmpty
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Order History"
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
        view.addSubview(orderHistoryIsEmpty)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            orderHistoryIsEmpty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orderHistoryIsEmpty.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 56)
        ])
    }
    
    // MARK: - Objc methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension OrderHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryTableCell.id, for: indexPath) as! OrderHistoryTableCell
        
        let order = orders[indexPath.row]
        let totalAmount = order.productCost + order.deliveryCharge - order.promoCodeDiscount
        
        guard let date = order.orderDate, let status = order.status else { return cell }
        
        let stringDate = dateFormatter.string(from: date)
        let stringAmount = "$\(String(format: "%.2f", totalAmount))"
        
        cell.configureCell(withStatus: status, date: stringDate, amount: stringAmount)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(OrderVC(order: orders[indexPath.row]), animated: true)
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

extension OrderHistoryVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
