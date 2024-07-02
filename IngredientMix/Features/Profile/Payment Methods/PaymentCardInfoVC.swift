//
//  PaymentCardInfoVC.swift
//  IngredientMix
//

import UIKit

class PaymentCardInfoVC: UIViewController {
    
    var cardData: CardEntity! {
        didSet {
            if let cutedNumber = cardData.cardNumber?.suffix(4) {
                cardNumberValueLabel.text = "#### #### #### \(cutedNumber)"
            }
            cardTitleLabel.text = cardData.cardName
            mmyyValueLabel.text = cardData.cardExpirationDate
            cardholderNameValueLabel.text = cardData.cardholderName
        }
    }
    
    var closePaymentCardInfoVCHandler: (() -> Void)!
    
    private lazy var cardTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 21, axis: [Constants.fontWeightAxis : 650])
        label.text = "Card"
        return label
    }()
    
    private lazy var cardSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.lightGraySectionColor
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var cardNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Card Number"
        return label
    }()
    
    private lazy var cardNumberView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ColorManager.shared.regularFieldBorderColor
        view.backgroundColor = ColorManager.shared.regularFieldColor
        return view
    }()
    
    private lazy var cardNumberValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var mmyyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "MM/YY"
        return label
    }()
    
    private lazy var mmyyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ColorManager.shared.regularFieldBorderColor
        view.backgroundColor = ColorManager.shared.regularFieldColor
        return view
    }()
    
    private lazy var mmyyValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var cvcLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "CVC"
        return label
    }()
    
    private lazy var cvcView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ColorManager.shared.regularFieldBorderColor
        view.backgroundColor = ColorManager.shared.regularFieldColor
        return view
    }()
    
    private lazy var cvcValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "###"
        return label
    }()
    
    private lazy var cardholderNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Cardholder Name"
        return label
    }()
    
    private lazy var cardholderNameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ColorManager.shared.regularFieldBorderColor
        view.backgroundColor = ColorManager.shared.regularFieldColor
        return view
    }()
    
    private lazy var cardholderNameValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "xmark", withConfiguration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.tintColor = ColorManager.shared.label
        button.backgroundColor = ColorManager.shared.headerElementsColor
        button.layer.cornerRadius = Constants.headerButtonSize / 2
        button.addTarget(self, action: #selector(closeButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(closeButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        view.layer.cornerRadius = 32
        
        view.addSubview(cardTitleLabel)
        view.addSubview(cardSectionView)
        view.addSubview(closeButton)
        
        cardSectionView.addSubview(cardNumberLabel)
        cardSectionView.addSubview(cardNumberView)
        cardNumberView.addSubview(cardNumberValueLabel)
        
        cardSectionView.addSubview(mmyyLabel)
        cardSectionView.addSubview(mmyyView)
        mmyyView.addSubview(mmyyValueLabel)
        
        cardSectionView.addSubview(cvcLabel)
        cardSectionView.addSubview(cvcView)
        cvcView.addSubview(cvcValueLabel)
        
        cardSectionView.addSubview(cardholderNameLabel)
        cardSectionView.addSubview(cardholderNameView)
        cardholderNameView.addSubview(cardholderNameValueLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            cardTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cardSectionView.topAnchor.constraint(equalTo: cardTitleLabel.bottomAnchor, constant: 32),
            cardSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardNumberLabel.topAnchor.constraint(equalTo: cardSectionView.topAnchor, constant: 32),
            cardNumberLabel.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            cardNumberView.topAnchor.constraint(equalTo: cardNumberLabel.bottomAnchor, constant: 8),
            cardNumberView.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            cardNumberView.trailingAnchor.constraint(equalTo: cardSectionView.trailingAnchor, constant: -16),
            cardNumberView.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            cardNumberValueLabel.centerYAnchor.constraint(equalTo: cardNumberView.centerYAnchor),
            cardNumberValueLabel.leadingAnchor.constraint(equalTo: cardNumberView.leadingAnchor, constant: 16),
            
            mmyyLabel.topAnchor.constraint(equalTo: cardNumberView.bottomAnchor, constant: 12),
            mmyyLabel.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            mmyyView.topAnchor.constraint(equalTo: mmyyLabel.bottomAnchor, constant: 8),
            mmyyView.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            mmyyView.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            mmyyView.widthAnchor.constraint(equalTo: cardSectionView.widthAnchor, multiplier: 0.5, constant: -20),
            mmyyValueLabel.centerYAnchor.constraint(equalTo: mmyyView.centerYAnchor),
            mmyyValueLabel.leadingAnchor.constraint(equalTo: mmyyView.leadingAnchor, constant: 16),
            
            cvcView.topAnchor.constraint(equalTo: mmyyView.topAnchor),
            cvcView.leadingAnchor.constraint(equalTo: mmyyView.trailingAnchor, constant: 8),
            cvcView.trailingAnchor.constraint(equalTo: cardSectionView.trailingAnchor, constant: -16),
            cvcView.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            cvcLabel.topAnchor.constraint(equalTo: mmyyLabel.topAnchor),
            cvcLabel.leadingAnchor.constraint(equalTo: cvcView.leadingAnchor),
            cvcValueLabel.centerYAnchor.constraint(equalTo: cvcView.centerYAnchor),
            cvcValueLabel.leadingAnchor.constraint(equalTo: cvcView.leadingAnchor, constant: 16),
            
            cardholderNameLabel.topAnchor.constraint(equalTo: mmyyView.bottomAnchor, constant: 12),
            cardholderNameLabel.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            cardholderNameView.topAnchor.constraint(equalTo: cardholderNameLabel.bottomAnchor, constant: 8),
            cardholderNameView.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            cardholderNameView.trailingAnchor.constraint(equalTo: cardSectionView.trailingAnchor, constant: -16),
            cardholderNameView.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            cardholderNameView.bottomAnchor.constraint(equalTo: cardSectionView.bottomAnchor, constant: -32),
            cardholderNameValueLabel.centerYAnchor.constraint(equalTo: cardholderNameView.centerYAnchor),
            cardholderNameValueLabel.leadingAnchor.constraint(equalTo: cardholderNameView.leadingAnchor, constant: 16),
            
            closeButton.heightAnchor.constraint(equalToConstant: Constants.headerButtonSize),
            closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - Objc methods
    
    @objc
    private func closeButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.closeButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func closeButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.closeButton.transform = CGAffineTransform.identity
        }, completion: nil)
        closePaymentCardInfoVCHandler()
    }
    
}

