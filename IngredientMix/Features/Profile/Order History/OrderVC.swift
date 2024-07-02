//
//  OrderVC.swift
//  IngredientMix
//

import UIKit

final class OrderVC: UIViewController {

    private let order: OrderEntity
    
    private lazy var backButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsBackButton()
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Order info section
    
    private lazy var orderInfoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.orderVC_SectionColor
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        label.text = "Info"
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        label.text = "Status"
        return label
    }()
    
    private lazy var statusValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .right
        label.text = order.status
        return label
    }()
    
    private lazy var orderDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        label.text = "Order date"
        return label
    }()
    
    private lazy var orderDateValueLabel: UILabel = {
        let label = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = formatter.string(from: order.orderDate!)
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var orderTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        label.text = "Order time"
        return label
    }()
    
    private lazy var orderTimeValueLabel: UILabel = {
        let label = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = formatter.string(from: order.orderDate!)
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        label.text = "Address"
        return label
    }()
    
    private lazy var addressValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .right
        label.text = order.address
        return label
    }()
    
    private lazy var paymentMethodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        label.text = "Payment Method"
        return label
    }()
    
    private lazy var paymentMethodValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .right
        label.text = order.paidByCard ? "Card" : "Cash"
        return label
    }()
    
    // MARK: - Order comments
    
    private lazy var commentsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.orderVC_SectionColor
        view.layer.cornerRadius = 24
        view.isHidden = true
        return view
    }()
    
    private lazy var commentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        label.text = "Comments"
        return label
    }()
    
    private lazy var commentsValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.text = order.orderComments
        return label
    }()
    
    // MARK: - Bill details section
    
    private lazy var billDetailsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.orderVC_SectionColor
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var billDetailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        label.text = "Bill Details"
        return label
    }()
    
    private lazy var orderItemStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        return stack
    }()
    
    private lazy var orderItemsDividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.labelGray.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var deliveryChargeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 400])
        label.text = "Delivery Charge"
        return label
    }()
    
    private lazy var deliveryChargeValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .right
        label.text = "$\(String(format: "%.2f", order.deliveryCharge))"
        return label
    }()
    
    private lazy var promoCodeDiscountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 400])
        label.text = "Promo Code Discount"
        return label
    }()
    
    private lazy var promoCodeDiscountValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textAlignment = .right
        if order.promoCodeDiscount.isZero {
            label.text = "-"
        } else {
            label.text = "$\(String(format: "%.2f", order.promoCodeDiscount))"
        }
        return label
    }()
        
    private lazy var totalAmountDividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.labelGray.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var totalAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 600])
        label.text = "Total Amount"
        return label
    }()
    
    private lazy var totalAmountValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .right
        label.text = "$\(String(format: "%.2f", order.productCost + order.deliveryCharge - order.promoCodeDiscount))"
        return label
    }()
    
    // MARK: - Lifecycle methods
    
    init(order: OrderEntity) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "Order"
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
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(orderInfoView)
        scrollView.addSubview(commentsView)
        scrollView.addSubview(billDetailsView)
        
        orderInfoView.addSubview(infoLabel)
        orderInfoView.addSubview(statusLabel)
        orderInfoView.addSubview(statusValueLabel)
        orderInfoView.addSubview(orderDateLabel)
        orderInfoView.addSubview(orderDateValueLabel)
        orderInfoView.addSubview(orderTimeLabel)
        orderInfoView.addSubview(orderTimeValueLabel)
        orderInfoView.addSubview(addressLabel)
        orderInfoView.addSubview(addressValueLabel)
        orderInfoView.addSubview(paymentMethodLabel)
        orderInfoView.addSubview(paymentMethodValueLabel)
        
        commentsView.addSubview(commentsLabel)
        commentsView.addSubview(commentsValueLabel)
        
        if let comments = order.orderComments, !comments.isEmpty {
            commentsView.isHidden = false
        }
        
        billDetailsView.addSubview(billDetailsLabel)
        billDetailsView.addSubview(orderItemStack)
        billDetailsView.addSubview(orderItemsDividerView)
        billDetailsView.addSubview(deliveryChargeLabel)
        billDetailsView.addSubview(deliveryChargeValueLabel)
        billDetailsView.addSubview(promoCodeDiscountLabel)
        billDetailsView.addSubview(promoCodeDiscountValueLabel)
        billDetailsView.addSubview(totalAmountDividerView)
        billDetailsView.addSubview(totalAmountLabel)
        billDetailsView.addSubview(totalAmountValueLabel)
        
        createOrderItemViews().forEach { subview in
            orderItemStack.addArrangedSubview(subview)
        }
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Order info section
            orderInfoView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32),
            orderInfoView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            orderInfoView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            orderInfoView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            
            infoLabel.topAnchor.constraint(equalTo: orderInfoView.topAnchor, constant: 24),
            infoLabel.leadingAnchor.constraint(equalTo: orderInfoView.leadingAnchor, constant: 24),
            
            statusLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: orderInfoView.leadingAnchor, constant: 24),
            statusValueLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            statusValueLabel.trailingAnchor.constraint(equalTo: orderInfoView.trailingAnchor, constant: -24),
            statusValueLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 16),
            
            orderDateLabel.topAnchor.constraint(equalTo: statusValueLabel.bottomAnchor, constant: 12),
            orderDateLabel.leadingAnchor.constraint(equalTo: orderInfoView.leadingAnchor, constant: 24),
            orderDateValueLabel.centerYAnchor.constraint(equalTo: orderDateLabel.centerYAnchor),
            orderDateValueLabel.trailingAnchor.constraint(equalTo: orderInfoView.trailingAnchor, constant: -24),
            orderDateValueLabel.leadingAnchor.constraint(equalTo: orderDateLabel.trailingAnchor, constant: 16),
            
            orderTimeLabel.topAnchor.constraint(equalTo: orderDateLabel.bottomAnchor, constant: 12),
            orderTimeLabel.leadingAnchor.constraint(equalTo: orderInfoView.leadingAnchor, constant: 24),
            orderTimeValueLabel.centerYAnchor.constraint(equalTo: orderTimeLabel.centerYAnchor),
            orderTimeValueLabel.trailingAnchor.constraint(equalTo: orderInfoView.trailingAnchor, constant: -24),
            orderTimeValueLabel.leadingAnchor.constraint(equalTo: orderTimeLabel.trailingAnchor, constant: 16),
            
            addressLabel.topAnchor.constraint(equalTo: orderTimeLabel.bottomAnchor, constant: 12),
            addressLabel.leadingAnchor.constraint(equalTo: orderInfoView.leadingAnchor, constant: 24),
            addressValueLabel.centerYAnchor.constraint(equalTo: addressLabel.centerYAnchor),
            addressValueLabel.trailingAnchor.constraint(equalTo: orderInfoView.trailingAnchor, constant: -24),
            addressValueLabel.leadingAnchor.constraint(equalTo: addressLabel.trailingAnchor, constant: 16),
            
            paymentMethodLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 12),
            paymentMethodLabel.leadingAnchor.constraint(equalTo: orderInfoView.leadingAnchor, constant: 24),
            paymentMethodLabel.bottomAnchor.constraint(equalTo: orderInfoView.bottomAnchor, constant: -24),
            paymentMethodValueLabel.centerYAnchor.constraint(equalTo: paymentMethodLabel.centerYAnchor),
            paymentMethodValueLabel.trailingAnchor.constraint(equalTo: orderInfoView.trailingAnchor, constant: -24),
            paymentMethodValueLabel.leadingAnchor.constraint(equalTo: paymentMethodLabel.trailingAnchor, constant: 16),
            
            // Order commetns
            commentsView.topAnchor.constraint(equalTo: orderInfoView.bottomAnchor, constant: 32),
            commentsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            commentsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            commentsView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            
            commentsLabel.topAnchor.constraint(equalTo: commentsView.topAnchor, constant: 24),
            commentsLabel.leadingAnchor.constraint(equalTo: commentsView.leadingAnchor, constant: 24),
            
            commentsValueLabel.topAnchor.constraint(equalTo: commentsLabel.bottomAnchor, constant: 16),
            commentsValueLabel.leadingAnchor.constraint(equalTo: commentsView.leadingAnchor, constant: 24),
            commentsValueLabel.trailingAnchor.constraint(equalTo: commentsView.trailingAnchor, constant: -24),
            commentsValueLabel.bottomAnchor.constraint(equalTo: commentsView.bottomAnchor, constant: -24),
            
            // Bill details section
            billDetailsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            billDetailsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            billDetailsView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            billDetailsView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            billDetailsLabel.topAnchor.constraint(equalTo: billDetailsView.topAnchor, constant: 24),
            billDetailsLabel.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 24),
            
            orderItemStack.topAnchor.constraint(equalTo: billDetailsLabel.bottomAnchor, constant: 12),
            orderItemStack.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 24),
            orderItemStack.trailingAnchor.constraint(equalTo: billDetailsView.trailingAnchor, constant: -24),
            
            orderItemsDividerView.topAnchor.constraint(equalTo: orderItemStack.bottomAnchor, constant: 6),
            orderItemsDividerView.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 24),
            orderItemsDividerView.trailingAnchor.constraint(equalTo: billDetailsView.trailingAnchor, constant: -24),
            orderItemsDividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            deliveryChargeLabel.topAnchor.constraint(equalTo: orderItemsDividerView.bottomAnchor, constant: 12),
            deliveryChargeLabel.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 24),
            deliveryChargeValueLabel.centerYAnchor.constraint(equalTo: deliveryChargeLabel.centerYAnchor),
            deliveryChargeValueLabel.trailingAnchor.constraint(equalTo: billDetailsView.trailingAnchor, constant: -24),
            
            promoCodeDiscountLabel.topAnchor.constraint(equalTo: deliveryChargeLabel.bottomAnchor, constant: 12),
            promoCodeDiscountLabel.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 24),
            promoCodeDiscountValueLabel.centerYAnchor.constraint(equalTo: promoCodeDiscountLabel.centerYAnchor),
            promoCodeDiscountValueLabel.trailingAnchor.constraint(equalTo: billDetailsView.trailingAnchor, constant: -24),
            
            totalAmountDividerView.topAnchor.constraint(equalTo: promoCodeDiscountLabel.bottomAnchor, constant: 12),
            totalAmountDividerView.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 24),
            totalAmountDividerView.trailingAnchor.constraint(equalTo: billDetailsView.trailingAnchor, constant: -24),
            totalAmountDividerView.heightAnchor.constraint(equalToConstant: 0.5),
            
            totalAmountLabel.topAnchor.constraint(equalTo: totalAmountDividerView.bottomAnchor, constant: 12),
            totalAmountLabel.leadingAnchor.constraint(equalTo: billDetailsView.leadingAnchor, constant: 24),
            totalAmountLabel.bottomAnchor.constraint(equalTo: billDetailsView.bottomAnchor, constant: -24),
            totalAmountValueLabel.centerYAnchor.constraint(equalTo: totalAmountLabel.centerYAnchor),
            totalAmountValueLabel.trailingAnchor.constraint(equalTo: billDetailsView.trailingAnchor, constant: -24)
        ])
        
        if let comments = order.orderComments, !comments.isEmpty {
            billDetailsView.topAnchor.constraint(equalTo: commentsView.bottomAnchor, constant: 32).isActive = true
        } else {
            billDetailsView.topAnchor.constraint(equalTo: orderInfoView.bottomAnchor, constant: 32).isActive = true
        }
    }
    
    private func createOrderItemViews() -> [UIView] {
        guard let orderItems = order.orderItems else { return [] }
        
        var views: [UIView] = []
        
        for item in orderItems {
            guard let item = item as? OrderItemEntity else { continue }
            
            let nameLabel: UILabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = ColorManager.shared.labelGray
                label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 400])
                label.text = item.dishName
                return label
            }()
            
            let quantityLabel: UILabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = ColorManager.shared.labelGray
                label.font = .systemFont(ofSize: 16, weight: .light)
                label.textAlignment = .center
                label.text = "\(item.quantity)"
                return label
            }()
            
            let priceLabel: UILabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = ColorManager.shared.label
                label.font = .systemFont(ofSize: 16, weight: .light)
                label.textAlignment = .right
                label.text = "$\(String(format: "%.2f", item.dishPrice))"
                return label
            }()
            
            let itemView = UIView()
            
            itemView.addSubview(nameLabel)
            itemView.addSubview(quantityLabel)
            itemView.addSubview(priceLabel)
            
            NSLayoutConstraint.activate([
                itemView.heightAnchor.constraint(equalToConstant: 32),
                nameLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
                nameLabel.leadingAnchor.constraint(equalTo: itemView.leadingAnchor),
                nameLabel.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -8),
                priceLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
                priceLabel.trailingAnchor.constraint(equalTo: itemView.trailingAnchor),
                priceLabel.widthAnchor.constraint(equalToConstant: 60),
                quantityLabel.centerYAnchor.constraint(equalTo: itemView.centerYAnchor),
                quantityLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -8),
                quantityLabel.widthAnchor.constraint(equalToConstant: 32)
            ])
            
            views.append(itemView)
            
        }
        
        return views
    }
    
    // MARK: - Objc methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension OrderVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
