//
//  PaymentVC.swift
//  IngredientMix
//

import UIKit
import GoogleMaps

final class PaymentVC: UIViewController {
    
    private let productCost: Double
    private let deliveryCharge: Double
    private let promoCodeDiscount: Double
    private var totalAmount: Double { productCost + deliveryCharge - promoCodeDiscount }
    private let orderItems: [OrderItemEntity]
    
    private var paymentMethodIsSelected: Bool!
    
    var deletePromocodeHandler: (() -> Void)?
    
    private var location: CLLocation? {
        didSet {
            updateMapView()
            if location != nil {
                unsetWarningOnAddressSection()
                hideMapBlurEffect()
            }
        }
    }
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
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
    
    private var paymentOptionsViewHeightConstraint: NSLayoutConstraint?
    private var totalAmountLabelTopConstraint: NSLayoutConstraint?
    
    //MARK: - Payment method section
    
    private lazy var paymentOptionsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.payment_sectionColor
        view.layer.cornerRadius = 36
        return view
    }()
    
    private lazy var payCashRadioButton: RadioButton = {
        let button = RadioButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(payCashRadioButtonTapped), for: .touchUpInside)
        button.associatedLabel = payCashLabel
        button.isSelected = false
        return button
    }()
    
    private lazy var payCashLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 550])
        label.text = "Pay cash to the courier"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(payCashRadioButtonTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var payByCardRadioButton: RadioButton = {
        let button = RadioButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(payByCardRadioButtonTapped), for: .touchUpInside)
        button.associatedLabel = payByCardLabel
        button.isSelected = true
        return button
    }()
    
    private lazy var payByCardLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 600])
        label.text = "Pay by card"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(payByCardRadioButtonTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var selectCardView: UIView = {
        let view = UIView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPaymentMethodsTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.payment_secondaryButtonColor
        view.layer.cornerRadius = 22
        return view
    }()

    private lazy var selectCardLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 550])
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var goToPaymentMethodsImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.shared.label
        return imageView
    }()
    
    //MARK: - Map section
    
    private lazy var mapSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.payment_sectionColor
        view.layer.cornerRadius = 36
        return view
    }()
    
    private lazy var geolocationButton: UIButton = {
        let image = UIImage(named: "Pin")
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 22
        button.backgroundColor = ColorManager.shared.payment_secondaryButtonColor
        button.tintColor = ColorManager.shared.label
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(geolocationButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(geolocationButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    private lazy var selectAddressView: UIView = {
        let view = UIView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToDeliveryAddressesTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.payment_secondaryButtonColor
        view.layer.cornerRadius = 22
        return view
    }()
    
    private lazy var selectedAddressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 550])
        label.text = "Add delivery address"
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var goToDeliveryAddressesImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.shared.label
        return imageView
    }()
    
    private lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: 41.6903308028158, longitude: 44.807368755121445, zoom: 17.0)
        let mapView = GMSMapView()
        mapView.camera = camera
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 20
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = ColorManager.shared.labelGray.withAlphaComponent(0.1).cgColor
        return mapView
    }()
    
    private lazy var mapBlurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()

    private lazy var mapVibrancyEffectView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: mapBlurEffectView.effect as! UIBlurEffect)
        let effectView = UIVisualEffectView(effect: vibrancyEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()
    
    private lazy var mapVibrancyImageView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(weight: .thin)
        let image = UIImage(systemName: "map", withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var marker: GMSMarker = {
        let marker = GMSMarker()
        if let customIcon = UIImage(named: "GooglePin") {
            marker.icon = customIcon
        }
        return marker
    }()
    
    //MARK: - Order comments section
    
    private lazy var orderCommentsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Order comments"
        return label
    }()
    
    private lazy var orderCommentsTextView: UITextView = {
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
    
    //MARK: - User agreement section

    private lazy var userAgreementCheckBox: CheckBox = {
        let checkbox = CheckBox()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.layer.cornerRadius = 5
        checkbox.layer.borderWidth = 1
        checkbox.layer.borderColor = ColorManager.shared.labelGray.cgColor
        checkbox.backgroundColor = ColorManager.shared.background
        checkbox.tintColor = ColorManager.shared.orange
        checkbox.addTarget(self, action: #selector(userAgreementCheckBoxDidTapped), for: .touchUpInside)
        checkbox.associatedLabel = userAgreementLabel
        checkbox.isChecked = false
        return checkbox
    }()
    
    private lazy var userAgreementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 550])
        label.text = "I habe read and accept the terms of use, rules of flight and privacy policy"
        label.numberOfLines = 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userAgreementCheckBoxDidTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    //MARK: - Place order section
    
    private lazy var placeOrderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.payment_totalAmountSection
        view.layer.cornerRadius = 36
        return view
    }()
    
    private lazy var seePriceDetailsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let normalTitle = NSAttributedString(string: "See price details",attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        let selectedTitle = NSAttributedString(string: "Hide price details",attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        button.setAttributedTitle(normalTitle, for: .normal)
        button.setAttributedTitle(selectedTitle, for: .selected)
        button.setTitleColor(ColorManager.shared.label, for: .normal)
        button.setTitleColor(ColorManager.shared.label.withAlphaComponent(0.5), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 13, axis: [Constants.fontWeightAxis : 550])
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(seePriceDetailsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var priceDetailsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private lazy var productCostLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 500])
        label.text = "Product Price"
        return label
    }()
    
    private lazy var productCostValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16)
        label.text = "$\(String(format: "%.2f", productCost))"
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
        return label
    }()
    
    private lazy var promoCodeDiscountValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = .systemFont(ofSize: 16)
        label.text = "$\(String(format: "%.2f", promoCodeDiscount))"
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
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 650])
        label.text = "Total Amount"
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.text = "$\(String(format: "%.2f", totalAmount))"
        return label
    }()
    
    private lazy var placeOrderButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ColorManager.shared.payment_placeOrderButtonColor
        button.layer.cornerRadius = 26
        button.setTitle("Place Order", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(placeOrderButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(placeOrderButtonTouchUp), for: [.touchUpInside, .touchUpOutside])
        return button
    }()
    
    // MARK: - Controller methods
    
    init(productCost: Double, deliveryCharge: Double, promoCodeDiscount: Double, orderItems: [OrderItemEntity]) {
        self.productCost = productCost
        self.deliveryCharge = deliveryCharge
        self.promoCodeDiscount = promoCodeDiscount
        self.orderItems = orderItems
        super.init(nibName: nil, bundle: nil)
        
        if deliveryCharge == promoCodeDiscount {
            deliveryChargeValueLabel.text = "$0.00"
            promoCodeDiscountValueLabel.text = "Free delivery"
        }
        
        if promoCodeDiscount.isZero {
            promoCodeDiscountValueLabel.text = "-"
        } else {
            promoCodeDiscountValueLabel.textColor = ColorManager.shared.confirmingGreen
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
        applyMapStyle()
        
        payCashRadioButton.alternateButton = [payByCardRadioButton]
        payByCardRadioButton.alternateButton = [payCashRadioButton]
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paymentMethodIsSelected = false
        DispatchQueue.main.async {
            if let preferredCardName = CoreDataManager.shared.getPreferredCardName() {
                self.selectCardLabel.text = preferredCardName
                self.paymentMethodIsSelected = true
                self.unsetWarningOnPaymentSection()
            } else {
                self.selectCardLabel.text = "Add payment card"
            }
            
            if let defaultAddress = CoreDataManager.shared.getDefaultAddress() {
                self.mapBlurEffectView.alpha = 0
                self.selectedAddressLabel.text = defaultAddress.placeName ?? "Add delivery address"
                self.location = CLLocation(latitude: defaultAddress.latitude, longitude: defaultAddress.longitude)
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyMapStyle()
        }
    }
    
    //MARK: - Private methods
    
    private func setupNavBar() {
        title = "Payment"
        
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
        
        scrollView.addSubview(paymentOptionsView)
        scrollView.addSubview(mapSectionView)
        scrollView.addSubview(orderCommentsLabel)
        scrollView.addSubview(orderCommentsTextView)
        scrollView.addSubview(userAgreementCheckBox)
        scrollView.addSubview(userAgreementLabel)
        scrollView.addSubview(placeOrderView)
        
        paymentOptionsView.addSubview(payCashRadioButton)
        paymentOptionsView.addSubview(payCashLabel)
        paymentOptionsView.addSubview(payByCardRadioButton)
        paymentOptionsView.addSubview(payByCardLabel)
        paymentOptionsView.addSubview(selectCardView)
        
        selectCardView.addSubview(selectCardLabel)
        selectCardView.addSubview(goToPaymentMethodsImageView)
        
        mapSectionView.addSubview(geolocationButton)
        mapSectionView.addSubview(selectAddressView)
        mapSectionView.addSubview(mapView)
        
        mapView.addSubview(mapBlurEffectView)
        mapBlurEffectView.contentView.addSubview(mapVibrancyEffectView)
        mapVibrancyEffectView.contentView.addSubview(mapVibrancyImageView)
        
        selectAddressView.addSubview(selectedAddressLabel)
        selectAddressView.addSubview(goToDeliveryAddressesImageView)
        
        placeOrderView.addSubview(seePriceDetailsButton)
        placeOrderView.addSubview(priceDetailsView)
        placeOrderView.addSubview(totalAmountLabel)
        placeOrderView.addSubview(priceLabel)
        placeOrderView.addSubview(placeOrderButton)
        
        priceDetailsView.addSubview(productCostLabel)
        priceDetailsView.addSubview(productCostValueLabel)
        priceDetailsView.addSubview(deliveryChargeLabel)
        priceDetailsView.addSubview(deliveryChargeValueLabel)
        priceDetailsView.addSubview(promoCodeDiscountLabel)
        priceDetailsView.addSubview(promoCodeDiscountValueLabel)
        priceDetailsView.addSubview(dividerView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Payment section
            paymentOptionsView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 32),
            paymentOptionsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            paymentOptionsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            paymentOptionsView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            
            payCashRadioButton.topAnchor.constraint(equalTo: paymentOptionsView.topAnchor, constant: 24),
            payCashRadioButton.leadingAnchor.constraint(equalTo: paymentOptionsView.leadingAnchor, constant: 24),
            payCashRadioButton.heightAnchor.constraint(equalToConstant: 20),
            payCashRadioButton.widthAnchor.constraint(equalToConstant: 20),
            
            payCashLabel.centerYAnchor.constraint(equalTo: payCashRadioButton.centerYAnchor),
            payCashLabel.leadingAnchor.constraint(equalTo: payCashRadioButton.trailingAnchor, constant: 8),
            
            payByCardRadioButton.topAnchor.constraint(equalTo: payCashRadioButton.bottomAnchor, constant: 24),
            payByCardRadioButton.leadingAnchor.constraint(equalTo: payCashRadioButton.leadingAnchor),
            payByCardRadioButton.heightAnchor.constraint(equalToConstant: 20),
            payByCardRadioButton.widthAnchor.constraint(equalToConstant: 20),
            
            payByCardLabel.centerYAnchor.constraint(equalTo: payByCardRadioButton.centerYAnchor),
            payByCardLabel.leadingAnchor.constraint(equalTo: payByCardRadioButton.trailingAnchor, constant: 8),
            
            selectCardView.leadingAnchor.constraint(equalTo: paymentOptionsView.leadingAnchor, constant: 16),
            selectCardView.trailingAnchor.constraint(equalTo: paymentOptionsView.trailingAnchor, constant: -16),
            selectCardView.bottomAnchor.constraint(equalTo: paymentOptionsView.bottomAnchor, constant: -16),
            selectCardView.heightAnchor.constraint(equalToConstant: 44),
            selectCardLabel.centerYAnchor.constraint(equalTo: selectCardView.centerYAnchor),
            selectCardLabel.leadingAnchor.constraint(equalTo: selectCardView.leadingAnchor, constant: 16),
            selectCardLabel.trailingAnchor.constraint(equalTo: goToPaymentMethodsImageView.leadingAnchor, constant: -16),
            
            goToPaymentMethodsImageView.centerYAnchor.constraint(equalTo: selectCardView.centerYAnchor),
            goToPaymentMethodsImageView.trailingAnchor.constraint(equalTo: selectCardView.trailingAnchor, constant: -12),
            goToPaymentMethodsImageView.heightAnchor.constraint(equalToConstant: 20),
            goToPaymentMethodsImageView.widthAnchor.constraint(equalTo: goToPaymentMethodsImageView.heightAnchor),
            
            // Address section
            mapSectionView.topAnchor.constraint(equalTo: paymentOptionsView.bottomAnchor, constant: 32),
            mapSectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            mapSectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            mapSectionView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            mapSectionView.heightAnchor.constraint(equalToConstant: 280),
            
            geolocationButton.topAnchor.constraint(equalTo: mapSectionView.topAnchor, constant: 16),
            geolocationButton.leadingAnchor.constraint(equalTo: mapSectionView.leadingAnchor, constant: 16),
            geolocationButton.heightAnchor.constraint(equalToConstant: 44),
            geolocationButton.widthAnchor.constraint(equalTo: geolocationButton.heightAnchor),
            
            selectAddressView.topAnchor.constraint(equalTo: mapSectionView.topAnchor, constant: 16),
            selectAddressView.leadingAnchor.constraint(equalTo: geolocationButton.trailingAnchor, constant: 12),
            selectAddressView.trailingAnchor.constraint(equalTo: mapSectionView.trailingAnchor, constant: -16),
            selectAddressView.heightAnchor.constraint(equalToConstant: 44),
            
            mapView.topAnchor.constraint(equalTo: geolocationButton.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: mapSectionView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: mapSectionView.trailingAnchor, constant: -16),
            mapView.bottomAnchor.constraint(equalTo: mapSectionView.bottomAnchor, constant: -16),
            
            selectedAddressLabel.centerYAnchor.constraint(equalTo: selectAddressView.centerYAnchor),
            selectedAddressLabel.leadingAnchor.constraint(equalTo: selectAddressView.leadingAnchor, constant: 16),
            selectedAddressLabel.trailingAnchor.constraint(equalTo: goToDeliveryAddressesImageView.leadingAnchor, constant: -16),
            
            goToDeliveryAddressesImageView.centerYAnchor.constraint(equalTo: selectAddressView.centerYAnchor),
            goToDeliveryAddressesImageView.trailingAnchor.constraint(equalTo: selectAddressView.trailingAnchor, constant: -12),
            goToDeliveryAddressesImageView.heightAnchor.constraint(equalToConstant: 20),
            goToDeliveryAddressesImageView.widthAnchor.constraint(equalTo: goToDeliveryAddressesImageView.heightAnchor),
            
            mapBlurEffectView.topAnchor.constraint(equalTo: mapView.topAnchor),
            mapBlurEffectView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            mapBlurEffectView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            mapBlurEffectView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor),
            
            mapVibrancyEffectView.topAnchor.constraint(equalTo: mapBlurEffectView.topAnchor),
            mapVibrancyEffectView.leadingAnchor.constraint(equalTo: mapBlurEffectView.leadingAnchor),
            mapVibrancyEffectView.trailingAnchor.constraint(equalTo: mapBlurEffectView.trailingAnchor),
            mapVibrancyEffectView.bottomAnchor.constraint(equalTo: mapBlurEffectView.bottomAnchor),
            
            mapVibrancyImageView.centerYAnchor.constraint(equalTo: mapVibrancyEffectView.centerYAnchor),
            mapVibrancyImageView.centerXAnchor.constraint(equalTo: mapVibrancyEffectView.centerXAnchor),
            mapVibrancyImageView.heightAnchor.constraint(equalToConstant: 80),
            mapVibrancyImageView.widthAnchor.constraint(equalTo: mapVibrancyImageView.heightAnchor),
            
            // Order comments section
            orderCommentsTextView.topAnchor.constraint(equalTo: mapSectionView.bottomAnchor, constant: 56),
            orderCommentsTextView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
            orderCommentsTextView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -32),
            orderCommentsTextView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -64),
            orderCommentsTextView.heightAnchor.constraint(equalToConstant: 96),
            
            orderCommentsLabel.bottomAnchor.constraint(equalTo: orderCommentsTextView.topAnchor, constant: -8),
            orderCommentsLabel.leadingAnchor.constraint(equalTo: orderCommentsTextView.leadingAnchor, constant: 16),
            
            // User agreement section
            userAgreementCheckBox.topAnchor.constraint(equalTo: orderCommentsTextView.bottomAnchor, constant: 32),
            userAgreementCheckBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            userAgreementCheckBox.widthAnchor.constraint(equalToConstant: Constants.checkboxSize),
            userAgreementCheckBox.heightAnchor.constraint(equalToConstant: Constants.checkboxSize),
            
            userAgreementLabel.topAnchor.constraint(equalTo: userAgreementCheckBox.topAnchor, constant: -4),
            userAgreementLabel.leadingAnchor.constraint(equalTo: userAgreementCheckBox.trailingAnchor, constant: 8),
            userAgreementLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Place order section
            placeOrderView.topAnchor.constraint(equalTo: userAgreementCheckBox.bottomAnchor, constant: 52),
            placeOrderView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            placeOrderView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            placeOrderView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            placeOrderView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            seePriceDetailsButton.topAnchor.constraint(equalTo: placeOrderView.topAnchor, constant: 24),
            seePriceDetailsButton.leadingAnchor.constraint(equalTo: placeOrderView.leadingAnchor, constant: 24),
            
            priceDetailsView.topAnchor.constraint(equalTo: seePriceDetailsButton.bottomAnchor, constant: 20),
            priceDetailsView.leadingAnchor.constraint(equalTo: placeOrderView.leadingAnchor, constant: 24),
            priceDetailsView.trailingAnchor.constraint(equalTo: placeOrderView.trailingAnchor, constant: -24),
            
            productCostLabel.topAnchor.constraint(equalTo: priceDetailsView.topAnchor),
            productCostLabel.leadingAnchor.constraint(equalTo: priceDetailsView.leadingAnchor),
            productCostValueLabel.centerYAnchor.constraint(equalTo: productCostLabel.centerYAnchor),
            productCostValueLabel.trailingAnchor.constraint(equalTo: priceDetailsView.trailingAnchor),
            
            deliveryChargeLabel.topAnchor.constraint(equalTo: productCostLabel.bottomAnchor, constant: 12),
            deliveryChargeLabel.leadingAnchor.constraint(equalTo: priceDetailsView.leadingAnchor),
            deliveryChargeValueLabel.centerYAnchor.constraint(equalTo: deliveryChargeLabel.centerYAnchor),
            deliveryChargeValueLabel.trailingAnchor.constraint(equalTo: priceDetailsView.trailingAnchor),
            
            promoCodeDiscountLabel.topAnchor.constraint(equalTo: deliveryChargeLabel.bottomAnchor, constant: 12),
            promoCodeDiscountLabel.leadingAnchor.constraint(equalTo: priceDetailsView.leadingAnchor),
            promoCodeDiscountValueLabel.centerYAnchor.constraint(equalTo: promoCodeDiscountLabel.centerYAnchor),
            promoCodeDiscountValueLabel.trailingAnchor.constraint(equalTo: priceDetailsView.trailingAnchor),
            
            dividerView.topAnchor.constraint(equalTo: promoCodeDiscountLabel.bottomAnchor, constant: 12),
            dividerView.leadingAnchor.constraint(equalTo: priceDetailsView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: priceDetailsView.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5),
            dividerView.bottomAnchor.constraint(equalTo: priceDetailsView.bottomAnchor),
            
            totalAmountLabel.leadingAnchor.constraint(equalTo: placeOrderView.leadingAnchor, constant: 24),
            
            priceLabel.centerYAnchor.constraint(equalTo: totalAmountLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: placeOrderView.trailingAnchor, constant: -24),
            
            placeOrderButton.topAnchor.constraint(equalTo: totalAmountLabel.bottomAnchor, constant: 28),
            placeOrderButton.leadingAnchor.constraint(equalTo: placeOrderView.leadingAnchor, constant: 16),
            placeOrderButton.trailingAnchor.constraint(equalTo: placeOrderView.trailingAnchor, constant: -16),
            placeOrderButton.bottomAnchor.constraint(equalTo: placeOrderView.bottomAnchor, constant: -16),
            placeOrderButton.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        paymentOptionsViewHeightConstraint = paymentOptionsView.heightAnchor.constraint(equalToConstant: 172)
        paymentOptionsViewHeightConstraint?.isActive = true
        
        totalAmountLabelTopConstraint = totalAmountLabel.topAnchor.constraint(equalTo: seePriceDetailsButton.bottomAnchor, constant: 14)
        totalAmountLabelTopConstraint?.isActive = true
    }
    
    private func updateMapView() {
        if let location = location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
            mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
            marker.map = mapView
            marker.position = location.coordinate
        }
    }
    
    private func hideMapBlurEffect() {
        UIView.animate(withDuration: 0.2) {
            self.mapBlurEffectView.alpha = 0
        }
    }
    
    private func getAddressFrom(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print(error)
                self.selectedAddressLabel.text = "Your geolocation"
            } else if let placemark = placemarks?.first {
                if let address = placemark.name {
                    self.selectedAddressLabel.text = address
                }
            }
        }
    }
    
    private func applyMapStyle() {
        let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        let styleFileName: String

        switch userInterfaceStyle {
        case .dark:
            styleFileName = "map_dark_style"
        default:
            styleFileName = "map_light_style"
        }

        if let styleURL = Bundle.main.url(forResource: styleFileName, withExtension: "json") {
            do {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } catch {
                ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Failed to load map style."])
                print("Failed to load map style. \(error)")
            }
        }
    }
    
    private func orderIsValid() -> Bool {
        var isValid = true
        
        if payByCardRadioButton.isSelected == true && !paymentMethodIsSelected {
            setWarningOnPaymentSection()
            isValid = false
        } else {
            unsetWarningOnPaymentSection()
        }

        if location == nil {
            let notification = UserNotification(message: "No geolocation detected. Please provide your current location or select an address for delivery.", type: .warning, interval: 4)
            notification.show(in: self.view)
            
            setWarningOnAddressSection()
            isValid = false
        } else {
            unsetWarningOnAddressSection()
        }
        
        if !userAgreementCheckBox.isChecked {
            userAgreementCheckBox.isInWarning = true
            isValid = false
        } else {
            userAgreementCheckBox.isInWarning = false
        }
        
        return isValid
    }
    
    private func setWarningOnPaymentSection() {
        selectCardView.layer.borderWidth = 1
        selectCardView.layer.borderColor = ColorManager.shared.warningRed.cgColor
    }
    
    private func unsetWarningOnPaymentSection() {
        selectCardView.layer.borderWidth = 0
        selectCardView.layer.borderColor = .none
    }
    
    private func setWarningOnAddressSection() {
        mapSectionView.layer.borderWidth = 1
        mapSectionView.layer.borderColor = ColorManager.shared.warningRed.cgColor
    }
    
    private func unsetWarningOnAddressSection() {
        mapSectionView.layer.borderWidth = 0
        mapSectionView.layer.borderColor = .none
    }
    
    private func showPriceDetails() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.priceDetailsView.alpha = 1
            self.totalAmountLabelTopConstraint?.constant = 118
            self.view.layoutIfNeeded()
        }
    }
    
    private func hidePriceDetails() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.priceDetailsView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.2) {
            self.totalAmountLabelTopConstraint?.constant = 14
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Objc methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func payCashRadioButtonTapped() {
        payCashRadioButton.isSelected = true
        payCashRadioButton.unselectAlternateButtons()
        unsetWarningOnPaymentSection()
        
        UIView.animate(withDuration: 0.2) {
            self.selectCardView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseInOut]) {
            self.paymentOptionsViewHeightConstraint?.constant = 112
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func payByCardRadioButtonTapped() {
        payByCardRadioButton.isSelected = true
        payByCardRadioButton.unselectAlternateButtons()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.paymentOptionsViewHeightConstraint?.constant = 172
            self.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.2) {
            self.selectCardView.alpha = 1
        }
    }
    
    @objc
    private func geolocationButtonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.geolocationButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc
    private func geolocationButtonTouchUp() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [], animations: {
            self.geolocationButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc
    private func goToPaymentMethodsTapped() {
        navigationController?.pushViewController(PaymentMethodsVC(), animated: true)
    }
    
    @objc
    private func goToDeliveryAddressesTapped() {
        navigationController?.pushViewController(DeliveryAddressesVC(), animated: true)
    }
    
    @objc
    private func userAgreementCheckBoxDidTapped() {
        userAgreementCheckBox.isChecked.toggle()
    }
    
    @objc
    private func seePriceDetailsButtonTapped() {
        UIView.performWithoutAnimation {
            seePriceDetailsButton.isSelected.toggle()
            seePriceDetailsButton.layoutIfNeeded()
        }
        
        if seePriceDetailsButton.isSelected {
            showPriceDetails()
        } else {
            hidePriceDetails()
        }
    }
    
    @objc
    private func placeOrderButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.placeOrderButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func placeOrderButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.placeOrderButton.transform = CGAffineTransform.identity
        }, completion: nil)

        if orderIsValid() {
            guard let location = location else { return }

            let orderID = UUID()
            
            Task {
                do {
                    try await OrderManager.shared.placeOrder(orderID: orderID,
                                                             productCost: productCost,
                                                             deliveryCharge: deliveryCharge,
                                                             promoCodeDiscount: promoCodeDiscount,
                                                             paidByCard: payByCardRadioButton.isSelected,
                                                             address: selectedAddressLabel.text ?? "",
                                                             latitude: location.coordinate.latitude,
                                                             longitude: location.coordinate.longitude,
                                                             orderComments: orderCommentsTextView.text,
                                                             phone: "",
                                                             orderItems: orderItems)
                    
                    try CoreDataManager.shared.clearCart()
                    
                    deletePromocodeHandler?()
                    navigationController?.popViewController(animated: true)
                } catch {
                    ErrorLogger.shared.logError(error, additionalInfo: ["OrderID": orderID, "UserID": UserManager.shared.getUserID()])
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

extension PaymentVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - CLLocationManagerDelegate

extension PaymentVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            getAddressFrom(location)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            let notification = UserNotification(message: "You have not given the app access to the location. You can change this in the iOS settings..", type: .error)
            notification.show(in: self)
            print("Geolocation is denied")
        }
        
        if status == .restricted {
            let notification = UserNotification(message: "The application is not authorized to access the location.", type: .error)
            notification.show(in: self)
            print("Geolocation is restricted")
        }
    }
}
