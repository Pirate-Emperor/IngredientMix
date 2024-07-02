//
//  FavoriteCell.swift
//  IngredientMix
//

import UIKit

final class FavoriteCell: UITableViewCell {
    
    static let id = "FavoriteCell"
    
    var favoriteDish: Dish! {
        didSet {
            setupUI()
            setupConstraints()
            
            productNameLabel.text = favoriteDish.name
            moreProductInfoLabel.text = "\(favoriteDish.weight)g / \(favoriteDish.calories)kcal"
            productPriceLabel.text = "$\(String(format: "%.2f", favoriteDish.price))"
            
            if favoriteDish.isOffer, let recentPrice = favoriteDish.recentPrice {
                let text = "$\(String(format: "%.2f", recentPrice))"
                let attributes: [NSAttributedString.Key: Any] = [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                productRecentPriceLabel.attributedText = attributedString
                setPriceConstraintWithOffer()
            } else {
                setPriceConstraintWithouOffer()
            }
            
            if let image = favoriteDish.imageData {
                producImageView.image = UIImage(data: image)
            } else {
                producImageView.image = UIImage(named: "EmptyPlate")
            }
        }
    }
    
    private lazy var productPriceLabelCenterYConstraint: NSLayoutConstraint = productPriceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0)
    
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
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 18, axis: [Constants.fontWeightAxis : 600])
        label.numberOfLines = 1
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        return label
    }()
    
    private lazy var moreProductInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var productRecentPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var productPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productRecentPriceLabel.attributedText = nil
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        backgroundColor = ColorManager.shared.background
        
        addSubview(producImageView)
        addSubview(productNameLabel)
        addSubview(moreProductInfoLabel)
        
        addSubview(productRecentPriceLabel)
        addSubview(productPriceLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            producImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            producImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            producImageView.heightAnchor.constraint(equalTo: heightAnchor, constant: -16),
            producImageView.widthAnchor.constraint(equalTo: producImageView.heightAnchor),
            
            productNameLabel.leadingAnchor.constraint(equalTo: producImageView.trailingAnchor, constant: 16),
            productNameLabel.trailingAnchor.constraint(equalTo: productPriceLabel.leadingAnchor, constant: -16),
            productNameLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -2),
            
            moreProductInfoLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: 2),
            moreProductInfoLabel.leadingAnchor.constraint(equalTo: productNameLabel.leadingAnchor),
            
            productRecentPriceLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -9),
            productRecentPriceLabel.centerXAnchor.constraint(equalTo: productPriceLabel.centerXAnchor),
            
            productPriceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            productPriceLabel.widthAnchor.constraint(equalToConstant: 64)
        ])
        
        productPriceLabelCenterYConstraint.isActive = true
    }
    
    private func setPriceConstraintWithOffer() {
        productPriceLabelCenterYConstraint.constant = 9
    }
    
    private func setPriceConstraintWithouOffer() {
        productPriceLabelCenterYConstraint.constant = 0
    }
}
