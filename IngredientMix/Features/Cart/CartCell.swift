//
//  CartCell.swift
//  IngredientMix
//

import UIKit

final class CartCell: UITableViewCell {
    
    static let id = "CartCell"
    
    var cartItemID: Int!
    
    var cartItem: CartItem! {
        didSet {
            setupUI()
            setupConstraints()
            
            productNameLabel.text = cartItem.dish.name
            productWeightLabel.text = "\(cartItem.dish.weight)g (1 pcs)"
            productPriceLabel.text = "$\(String(format: "%.2f", cartItem.dish.price))"
            quantityLabel.text = String(cartItem.quantity)
            checkAmountLabelTextColor()
            
            if let image = cartItem.dish.imageData {
                producImageView.image = UIImage(data: image)
            } else {
                producImageView.image = UIImage(named: "EmptyPlate")
            }
        }
    }
    
    var cartItemImageBackColor: UIColor = ColorManager.shared.green {
        didSet {
            imageColorBackground.backgroundColor = cartItemImageBackColor
        }
    }
    
    var itemQuantityHandler: ((Int, Int) -> Void)!
    
    private let amountOfProductViewWidth = 47.0
    private let plusMinusButtonsSize = 20.0
    
    private lazy var imageColorBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = cartItemImageBackColor
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var producImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var productNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 650])
        return label
    }()
    
    private lazy var productWeightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var productPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var productQuantityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.cartCell_amountBlockColor
        view.layer.cornerRadius = amountOfProductViewWidth / 2
        return view
    }()
    
    private lazy var minusItemButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let image = UIImage(systemName: "minus", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ColorManager.shared.background
        button.tintColor = ColorManager.shared.label
        button.layer.cornerRadius = plusMinusButtonsSize / 2
        button.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var plusItemButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        let image = UIImage(systemName: "plus", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ColorManager.shared.label
        button.tintColor = ColorManager.shared.background
        button.layer.cornerRadius = plusMinusButtonsSize / 2
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 17)
        label.text = "1"
        return label
    }()
    
    private func setupUI() {
        backgroundColor = ColorManager.shared.background
        
        addSubview(imageColorBackground)
        addSubview(productNameLabel)
        addSubview(productWeightLabel)
        addSubview(productPriceLabel)
        addSubview(productQuantityView)
        
        imageColorBackground.addSubview(producImageView)
        
        productQuantityView.addSubview(minusItemButton)
        productQuantityView.addSubview(plusItemButton)
        productQuantityView.addSubview(quantityLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageColorBackground.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageColorBackground.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageColorBackground.heightAnchor.constraint(equalToConstant: 92),
            imageColorBackground.widthAnchor.constraint(equalTo: imageColorBackground.heightAnchor),
            producImageView.centerXAnchor.constraint(equalTo: imageColorBackground.centerXAnchor),
            producImageView.centerYAnchor.constraint(equalTo: imageColorBackground.centerYAnchor),
            producImageView.heightAnchor.constraint(equalTo: imageColorBackground.heightAnchor, constant: -20),
            producImageView.widthAnchor.constraint(equalTo: producImageView.heightAnchor),
            
            productNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            productNameLabel.leadingAnchor.constraint(equalTo: imageColorBackground.trailingAnchor, constant: 12),
            productNameLabel.trailingAnchor.constraint(equalTo: productQuantityView.leadingAnchor, constant: -12),
            productWeightLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 4),
            productWeightLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            productPriceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            productPriceLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            
            productQuantityView.centerYAnchor.constraint(equalTo: centerYAnchor),
            productQuantityView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            productQuantityView.heightAnchor.constraint(equalToConstant: 88),
            productQuantityView.widthAnchor.constraint(equalToConstant: amountOfProductViewWidth),
            plusItemButton.centerXAnchor.constraint(equalTo: productQuantityView.centerXAnchor),
            plusItemButton.topAnchor.constraint(equalTo: productQuantityView.topAnchor, constant: 10),
            plusItemButton.widthAnchor.constraint(equalToConstant: plusMinusButtonsSize),
            plusItemButton.heightAnchor.constraint(equalToConstant: plusMinusButtonsSize),
            minusItemButton.centerXAnchor.constraint(equalTo: productQuantityView.centerXAnchor),
            minusItemButton.bottomAnchor.constraint(equalTo: productQuantityView.bottomAnchor, constant: -10),
            minusItemButton.widthAnchor.constraint(equalToConstant: plusMinusButtonsSize),
            minusItemButton.heightAnchor.constraint(equalToConstant: plusMinusButtonsSize),
            quantityLabel.centerXAnchor.constraint(equalTo: productQuantityView.centerXAnchor),
            quantityLabel.centerYAnchor.constraint(equalTo: productQuantityView.centerYAnchor)
        ])
    }
    
    private func checkAmountLabelTextColor() {
        quantityLabel.textColor = quantityLabel.text == "0" ? ColorManager.shared.labelGray.withAlphaComponent(0.5) : ColorManager.shared.label
    }
    
    @objc
    private func minusButtonTapped() {
        var quantity = Int(quantityLabel.text ?? "0") ?? 0
        if quantity > 0 {
            quantity -= 1
            quantityLabel.text = "\(quantity)"
        }
        checkAmountLabelTextColor()
        itemQuantityHandler(cartItemID, quantity)
    }
    
    @objc
    private func plusButtonTapped() {
        var quantity = Int(quantityLabel.text ?? "0") ?? 0
        quantity += 1
        quantityLabel.text = "\(quantity)"
        checkAmountLabelTextColor()
        itemQuantityHandler(cartItemID, quantity)
    }
}
