//
//  TabBarVC.swift
//  IngredientMix
//

import UIKit

final class DishCell: UICollectionViewCell {
    static let id = "DishCell"
    
    var dishData: Dish! {
        didSet {
            nameLabel.text = dishData.name
            actualPriceLabel.text = "$\(String(format: "%.2f", dishData.price))"
            
            if dishData.isOffer, let recentPrice = dishData.recentPrice {
                let text = "$\(String(format: "%.2f", recentPrice))"
                let attributes: [NSAttributedString.Key: Any] = [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                regularPriceLabel.attributedText = attributedString
            }
            
            if let data = dishData.imageData {
                dishImage.image = UIImage(data: data)
            }
        }
    }
    
    var isFavorite: Bool! {
        didSet {
            favoriteButton.isSelected = isFavorite
        }
    }
    
    var isFavoriteDidChange: ((Bool) -> Void)!
    
    lazy var customShapeView: DishCellShapeView = {
        let view = DishCellShapeView()
        view.frame = bounds
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = ColorManager.shared.background
        button.backgroundColor = ColorManager.shared.label
        button.addTarget(self, action: #selector(addButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(addButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    private lazy var dishImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "test")
        view.frame = CGRect(x: 20, y: 10, width: bounds.width - 40, height: bounds.width - 40)
        view.layer.cornerRadius = (bounds.width - 40) / 2
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Classic Delux Burger"
        label.font = UIFont(name: "Raleway", size: 14)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private lazy var actualPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "$4.00"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var regularPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.textColor = ColorManager.shared.labelGray
        label.textAlignment = .left
        return label
    }()
    
    private lazy var startingFromLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Starting From"
        label.font = .systemFont(ofSize: 9, weight: .light)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton()
        let imageOff = UIImage(named: "Favorite-litle-off")
        let imageOn = UIImage(named: "Favorite-litle-on")
        button.setImage(imageOff, for: .normal)
        button.setImage(imageOn, for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ColorManager.shared.dishCell_FavoriteButtonColor
        button.tintColor = ColorManager.shared.label
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(favoriteButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        regularPriceLabel.attributedText = nil
    }
    
    private func setupUI() {
        addSubview(customShapeView)
        addSubview(addButton)
        addSubview(nameLabel)
        addSubview(favoriteButton)
        addSubview(actualPriceLabel)
        addSubview(regularPriceLabel)
        addSubview(startingFromLabel)
        
        customShapeView.addSubview(dishImage)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            addButton.widthAnchor.constraint(equalToConstant: frame.width / 4.7),
            addButton.heightAnchor.constraint(equalToConstant: frame.width / 4.7),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -48),
            nameLabel.heightAnchor.constraint(equalToConstant: 24),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            favoriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            actualPriceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            actualPriceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            actualPriceLabel.heightAnchor.constraint(equalToConstant: 20),
            regularPriceLabel.leadingAnchor.constraint(equalTo: actualPriceLabel.trailingAnchor, constant: 6),
            regularPriceLabel.bottomAnchor.constraint(equalTo: actualPriceLabel.bottomAnchor),
            regularPriceLabel.heightAnchor.constraint(equalTo: actualPriceLabel.heightAnchor),
            startingFromLabel.bottomAnchor.constraint(equalTo: actualPriceLabel.topAnchor),
            startingFromLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            startingFromLabel.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    @objc 
    private func addButtonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.addButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }
    }
    
    @objc 
    private func addButtonTouchUp() {
        do {
            try CoreDataManager.shared.saveCartItem(dish: dishData, quantity: 1)
        } catch {
            let notification = UserNotification(message: "Failed to add dish to cart. Please try again.", type: .error)
            notification.showGlobally()
        }
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [], animations: {
            self.addButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @objc
    private func favoriteButtonDidTapped() {
        isFavorite.toggle()
        isFavoriteDidChange(isFavorite)
        if favoriteButton.isSelected {
            do {
                try CoreDataManager.shared.setAsFavorite(by: dishData.id)
            } catch {
                let notification = UserNotification(message: "Failed to add dish to favorites. Please try again.", type: .error)
                notification.showGlobally()
            }
        } else {
            do {
                try CoreDataManager.shared.deleteFromFavorite(by: dishData.id)
            } catch {
                let notification = UserNotification(message: "Failed to remove dish from favorites. Please try again.", type: .error)
                notification.showGlobally()
            }
        }
    }
    
}
