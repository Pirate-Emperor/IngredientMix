//
//  TabBarVC.swift
//  IngredientMix
//

import UIKit

final class CartTabVC: UIViewController {
    
    lazy var cartContent: [CartItem] = [] {
        didSet {
            updateBill()
            
            if cartItemColors.count != cartContent.count {
                cartItemColors = ColorManager.shared.getColors(cartContent.count)
            }
            
            if cartContent.isEmpty {
                emptyCartView.isHidden = false
                scrollView.isHidden = true
            } else {
                emptyCartView.isHidden = true
                scrollView.isHidden = false
            }
        }
    }

    private let cartCellHeight: CGFloat = 110
    
    private var cartItemColors: [UIColor] = []
        
    private var activePromoCode: PromoCodeEntity?

    private var productCost: Double = 0
    private var deliveryCharge: Double = 2.0
    private var promoCodeDiscount: Double = 0
    private var totalAmount: Double = 0
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var dividerTopAnchorConstraint: NSLayoutConstraint?
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = ColorManager.shared.background
        table.separatorStyle = .none
        table.allowsSelection = false
        table.isScrollEnabled = false
        table.register(CartCell.self, forCellReuseIdentifier: CartCell.id)
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    private let spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Promo code block props.
    
    private let promoCodeViewHeight: CGFloat = 68
    private let promoCodeViewPadding: CGFloat = 10
    
    private lazy var promoCodeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.cart_promoCodeViewColor
        view.layer.cornerRadius = promoCodeViewHeight / 2
        return view
    }()
    
    private lazy var promoCodeTextField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Promo Code"
        field.autocapitalizationType = .allCharacters
        field.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 600])
        field.textColor = ColorManager.shared.label
        field.tintColor = ColorManager.shared.orange
        return field
    }()
    
    private lazy var applyCodeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = (promoCodeViewHeight - promoCodeViewPadding*2) / 2
        button.backgroundColor = ColorManager.shared.cart_applyCodeButtonColor
        button.setTitle("Apply Code", for: .normal)
        button.setTitleColor(ColorManager.shared.background, for: .normal)
        button.setTitleColor(ColorManager.shared.background.withAlphaComponent(0.7), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(applyCodeButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(applyCodeButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    // MARK: - Bill details block props.
    
    private lazy var billDetailsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.cart_billDetailsViewColor
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var billDetailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 750])
        label.text = "Bill Details"
        return label
    }()
    
    private lazy var productCostLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 500])
        label.text = "Product Cost"
        return label
    }()
    
    private lazy var productCostValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var deliveryChargeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 500])
        label.text = "Delivery Charge"
        return label
    }()
    
    private lazy var deliveryChargeValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16)
        label.text = "$\(String(format: "%.2f", deliveryCharge))"
        return label
    }()
    
    private lazy var promoCodeDiscountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 500])
        label.text = "Promo Code Discount"
        label.alpha = 0
        return label
    }()
    
    private lazy var promoCodeDiscountValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.confirmingGreen
        label.font = .systemFont(ofSize: 16)
        label.alpha = 0
        return label
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.labelGray.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var totalAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 700])
        label.text = "Total Amount"
        return label
    }()
    
    private lazy var totalAmountValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var continueOrderButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 26
        button.backgroundColor = ColorManager.shared.regularButtonColor
        button.setTitle("Continue Order", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(continueOrderButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(continueOrderButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    // MARK: - Empty cart view props.
    
    private lazy var emptyCartView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = false
        return view
    }()
    
    private lazy var cartIsEmptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = ColorManager.shared.label
        label.text = "Cart Is Empty"
        label.font = UIFont(name: "Raleway", size: 22)
        label.numberOfLines = 1
        label.layer.shadowOffset = CGSize(width: 3, height: 3)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        return label
    }()
    
    private lazy var emptyCartImageView: UIImageView = {
        let image = UIImage(named: "EmptyCart")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
        checkPromoCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        do {
            try CoreDataManager.shared.saveCart(cartContent)
        } catch {
            let notification = UserNotification(message: "Failed to save cart data.", type: .error)
            notification.show(in: self)
        }
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Cart"
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorManager.shared.label,
            .font: UIFont.getVariableVersion(of: "Raleway", size: 21, axis: [Constants.fontWeightAxis : 650])
        ]
        
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        
        view.addSubview(emptyCartView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(tableView)
        scrollView.addSubview(promoCodeView)
        scrollView.addSubview(billDetailsView)
        scrollView.addSubview(spacerView)
        
        promoCodeView.addSubview(promoCodeTextField)
        promoCodeView.addSubview(applyCodeButton)
        billDetailsView.addSubview(billDetailsLabel)
        billDetailsView.addSubview(productCostLabel)
        billDetailsView.addSubview(productCostValueLabel)
        billDetailsView.addSubview(deliveryChargeLabel)
        billDetailsView.addSubview(deliveryChargeValueLabel)
        billDetailsView.addSubview(promoCodeDiscountLabel)
        billDetailsView.addSubview(promoCodeDiscountValueLabel)
        billDetailsView.addSubview(dividerView)
        billDetailsView.addSubview(totalAmountLabel)
        billDetailsView.addSubview(totalAmountValueLabel)
        billDetailsView.addSubview(continueOrderButton)
        
        emptyCartView.addSubview(cartIsEmptyLabel)
        emptyCartView.addSubview(emptyCartImageView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            tableView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            promoCodeView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 40),
            promoCodeView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            promoCodeView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            promoCodeView.heightAnchor.constraint(equalToConstant: promoCodeViewHeight),
            promoCodeView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            applyCodeButton.heightAnchor.constraint(equalToConstant: promoCodeViewHeight - promoCodeViewPadding*2),
            applyCodeButton.centerYAnchor.constraint(equalTo: promoCodeView.centerYAnchor),
            applyCodeButton.trailingAnchor.constraint(equalTo: promoCodeView.trailingAnchor, constant: -promoCodeViewPadding),
            applyCodeButton.widthAnchor.constraint(equalToConstant: 140),
            promoCodeTextField.centerYAnchor.constraint(equalTo: promoCodeView.centerYAnchor),
            promoCodeTextField.leadingAnchor.constraint(equalTo: promoCodeView.leadingAnchor, constant: 18),
            promoCodeTextField.trailingAnchor.constraint(equalTo: applyCodeButton.leadingAnchor, constant: -promoCodeViewPadding),
            
            billDetailsView.topAnchor.constraint(equalTo: promoCodeView.bottomAnchor, constant: 12),
            billDetailsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            billDetailsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            billDetailsView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            billDetailsLabel.topAnchor.constraint(equalTo: billDetailsView.topAnchor, constant: 32),
            billDetailsLabel.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 16),
            productCostLabel.topAnchor.constraint(equalTo: billDetailsLabel.bottomAnchor, constant: 16),
            productCostLabel.leadingAnchor.constraint(equalTo: billDetailsLabel.leadingAnchor),
            productCostValueLabel.centerYAnchor.constraint(equalTo: productCostLabel.centerYAnchor),
            productCostValueLabel.trailingAnchor.constraint(equalTo: billDetailsView.trailingAnchor, constant: -12),
            deliveryChargeLabel.topAnchor.constraint(equalTo: productCostLabel.bottomAnchor, constant: 16),
            deliveryChargeLabel.leadingAnchor.constraint(equalTo: billDetailsLabel.leadingAnchor),
            deliveryChargeValueLabel.centerYAnchor.constraint(equalTo: deliveryChargeLabel.centerYAnchor),
            deliveryChargeValueLabel.trailingAnchor.constraint(equalTo: productCostValueLabel.trailingAnchor),
            promoCodeDiscountLabel.topAnchor.constraint(equalTo: deliveryChargeLabel.bottomAnchor, constant: 16),
            promoCodeDiscountLabel.leadingAnchor.constraint(equalTo: deliveryChargeLabel.leadingAnchor),
            promoCodeDiscountValueLabel.centerYAnchor.constraint(equalTo: promoCodeDiscountLabel.centerYAnchor),
            promoCodeDiscountValueLabel.trailingAnchor.constraint(equalTo: deliveryChargeValueLabel.trailingAnchor),
            dividerView.leadingAnchor.constraint(equalTo: billDetailsLabel.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: productCostValueLabel.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5),
            totalAmountLabel.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 10),
            totalAmountLabel.leadingAnchor.constraint(equalTo: billDetailsLabel.leadingAnchor),
            totalAmountValueLabel.centerYAnchor.constraint(equalTo: totalAmountLabel.centerYAnchor),
            totalAmountValueLabel.trailingAnchor.constraint(equalTo: productCostValueLabel.trailingAnchor),
            continueOrderButton.topAnchor.constraint(equalTo: totalAmountLabel.bottomAnchor, constant: 32),
            continueOrderButton.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 16),
            continueOrderButton.trailingAnchor.constraint(equalTo: billDetailsView.trailingAnchor, constant: -16),
            continueOrderButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            continueOrderButton.bottomAnchor.constraint(equalTo: billDetailsView.bottomAnchor, constant: -18),
            
            spacerView.topAnchor.constraint(equalTo: billDetailsView.bottomAnchor),
            spacerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            spacerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            spacerView.heightAnchor.constraint(equalToConstant: 92),
            spacerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            emptyCartView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            emptyCartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyCartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyCartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            cartIsEmptyLabel.centerXAnchor.constraint(equalTo: emptyCartView.centerXAnchor),
            cartIsEmptyLabel.topAnchor.constraint(equalTo: emptyCartView.topAnchor, constant: 100),
            emptyCartImageView.topAnchor.constraint(equalTo: cartIsEmptyLabel.bottomAnchor, constant: 32),
            emptyCartImageView.centerXAnchor.constraint(equalTo: emptyCartView.centerXAnchor),
            emptyCartImageView.heightAnchor.constraint(equalToConstant: 285),
            emptyCartImageView.widthAnchor.constraint(equalToConstant: 255)
            
        ])
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        
        dividerTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: deliveryChargeLabel.bottomAnchor, constant: 13)
        dividerTopAnchorConstraint?.isActive = true
    }
    
    private func updateTableViewHeight() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        tableViewHeightConstraint?.constant = CGFloat(numberOfRows) * cartCellHeight
    }
    
    private func checkCart() {
        do {
            let items = try CoreDataManager.shared.fetchCart()
            if cartContent != items {
                cartContent = items
                tableView.reloadData()
                updateTableViewHeight()
            }
        } catch {
            ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when loading a cart from storage."])
            
            let notification = UserNotification(message: "Failed to check cart data.", type: .error)
            notification.show(in: self)
        }
    }
    
    private func checkPromoCode() {
        if PromoCodeManager.shared.isActivePromoInStorage() {
            do {
                let promoCode = try PromoCodeManager.shared.fetchPromoCode()
                
                if promoCode.expirationDate! > Date() {
                    activePromoCode = promoCode
                    showDiscount()
                } else {
                    let notification = UserNotification(message: "Your promo code has expired.", type: .warning)
                    notification.show(in: self)
                    
                    try PromoCodeManager.shared.deletePromoCode()
                }
            } catch {
                ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error while trying to download promo code from storage."])
                
                let notification = UserNotification(message: "An internal error occurred while processing a promo code.", type: .error)
                notification.show(in: self)
            }
        }
    }
    
    private func deletePromoCode() {
        activePromoCode = nil
        deliveryCharge = 2
        promoCodeDiscount = 0
        promoCodeDiscountValueLabel.text = ""
        deliveryChargeValueLabel.text = "$\(String(format: "%.2f", deliveryCharge))"
        
        hideDiscount()
        
        do {
            try PromoCodeManager.shared.deletePromoCode()
        } catch {
            ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to delete promo code from storage."])
        }
    }
    
    private func updateBill() {
        if let promoCode = activePromoCode {
            var totalDiscount = 0.0
            
            if promoCode.freeDelivery {
                totalDiscount = deliveryCharge
                promoCodeDiscountValueLabel.text = "Free delivery"
                deliveryChargeValueLabel.text = "$0.00"
            } else {
                totalDiscount = (productCost / 100 * Double(promoCode.discountPercentage) * 100).rounded() / 100
                promoCodeDiscountValueLabel.text = "-$\(String(format: "%.2f", totalDiscount))"
            }
            
            promoCodeDiscount = totalDiscount
        }
        
        productCost = 0
        
        for item in cartContent {
            productCost += Double(item.quantity) * item.dish.price
        }
        
        totalAmount = productCost + deliveryCharge - promoCodeDiscount
        
        productCostValueLabel.text = "$\(String(format: "%.2f", productCost))"
        totalAmountValueLabel.text = "$\(String(format: "%.2f", totalAmount))"
    }
    
    private func deleteCartItem(at indexPath: IndexPath) {
        do {
            let itemToDelete = cartContent[indexPath.row]
            try CoreDataManager.shared.deleteCartItem(by: itemToDelete.dish.id)
            
            cartItemColors.remove(at: indexPath.row)
            cartContent.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            let notification = UserNotification(message: "Failed to remove dish from cart. Please try again.", type: .error)
            notification.show(in: self)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.updateTableViewHeight()
            self.view.layoutIfNeeded()
        }
    }
    
    private func getOrderItems() -> [OrderItemEntity] {
        var orderItems: [OrderItemEntity] = []
                
        for item in cartContent {
            let orderItem = OrderItemEntity(context: CoreDataManager.shared.context)
            orderItem.dishID = item.dish.id
            orderItem.dishName = item.dish.name
            orderItem.dishPrice = item.dish.price
            orderItem.quantity = Int64(item.quantity)
            
            orderItems.append(orderItem)
        }
        
        return orderItems
    }
    
    private func showDiscountWithAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 80, initialSpringVelocity: 0.5) {
            self.promoCodeDiscountLabel.alpha = 1
            self.promoCodeDiscountValueLabel.alpha = 1
            self.dividerTopAnchorConstraint?.constant = 42
            self.view.layoutIfNeeded()
        }
    }
    
    private func showDiscount() {
        promoCodeDiscountLabel.alpha = 1
        promoCodeDiscountValueLabel.alpha = 1
        dividerTopAnchorConstraint?.constant = 42
    }
    
    private func hideDiscount() {
        promoCodeDiscountLabel.alpha = 0
        promoCodeDiscountValueLabel.alpha = 0
        dividerTopAnchorConstraint?.constant = 13
    }
    
    // MARK: - ObjC methods

    @objc
    private func applyCodeButtonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.applyCodeButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func applyCodeButtonTouchUp() {
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [], animations: {
            self.applyCodeButton.transform = CGAffineTransform.identity
        }, completion: nil)
        
        guard let code = promoCodeTextField.text, !code.isEmpty else { return }
        
        Task {
            do {
                let promoCode = try await PromoCodeManager.shared.applyPromoCode(code)
                activePromoCode = promoCode
                updateBill()
                showDiscountWithAnimation()
                
                promoCodeTextField.text = ""
                promoCodeTextField.resignFirstResponder()
                
                let notification = UserNotification(message: "The promo code has been successfully applied.", type: .confirming, interval: 4)
                notification.show(in: self)
                
            } catch {
                ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to apply promo code."])
                promoCodeTextField.text = ""
                UserNotification.show(for: error, in: self)
            }
        }
    }
    
    @objc
    private func continueOrderButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.continueOrderButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func continueOrderButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.continueOrderButton.transform = CGAffineTransform.identity
        }, completion: nil)

        let orderItems = getOrderItems()
        let vc = PaymentVC(productCost: productCost, deliveryCharge: deliveryCharge, promoCodeDiscount: promoCodeDiscount, orderItems: orderItems)
        
        if !promoCodeDiscount.isZero {
            vc.deletePromocodeHandler = { [weak self] in
                self?.deletePromoCode()
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView delegate methods

extension CartTabVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cartContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartCell.id, for: indexPath) as! CartCell
        cell.cartItemID = indexPath.row
        cell.cartItem = cartContent[indexPath.row]
        cell.cartItemImageBackColor = cartItemColors[indexPath.row]
        cell.itemQuantityHandler = { [weak self] id, quantity in
            self?.cartContent[id].quantity = quantity
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        cartCellHeight
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            self?.deleteCartItem(at: indexPath)
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
}
