//
//  OfferCell.swift
//  IngredientMix
//

import UIKit

final class OfferCell: UICollectionViewCell {
    static let id = "OfferCell"
    
    lazy var offerData: Offer = Offer(id: "", name: "", amount: "", condition: "", imageData: nil) {
        didSet {
            titleLabel.text = offerData.name
            offerLabel.text = offerData.amount
            conditionLabel.text = offerData.condition
            
            if let data = offerData.imageData {
                offerImage.image = UIImage(data: data)
            }
            
            conditionLabelWidth = NSString(string: offerData.condition).width(withFont: conditionLabelFont) + 32
            conditionLabelWidthConstraint.constant = conditionLabelWidth
            layoutIfNeeded()
            
            animateOfferImage()
        }
    }
    
    lazy var primaryColor = ColorManager.shared.green {
        didSet {
            updateGradients()
        }
    }
    
    private let conditionLabelFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
    private var conditionLabelWidth: CGFloat = 0
    private lazy var conditionLabelWidthConstraint = conditionLabel.widthAnchor.constraint(equalToConstant: conditionLabelWidth)
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 18, axis: [Constants.fontWeightAxis : 800])
        return label
    }()
        
    private lazy var offerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.frame.size = CGSize(width: 130, height: 40)
        label.font = .systemFont(ofSize: 50, weight: .bold)
        return label
    }()

    private lazy var conditionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        label.font = conditionLabelFont
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = ColorManager.shared.orange
        return label
    }()
    
    private lazy var offerImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        view.frame = bounds
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0.5
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradients()
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 16
        
        addSubview(gradientView)
        addSubview(titleLabel)
        addSubview(offerLabel)
        addSubview(conditionLabel)
        addSubview(offerImage)
        
        updateGradients()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            offerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            offerLabel.bottomAnchor.constraint(equalTo: conditionLabel.topAnchor, constant: 5),
            offerLabel.heightAnchor.constraint(equalToConstant: 40),
            offerImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            offerImage.leadingAnchor.constraint(equalTo: trailingAnchor, constant: -132),
            offerImage.widthAnchor.constraint(equalToConstant: 140),
            offerImage.heightAnchor.constraint(equalToConstant: 140),
            conditionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            conditionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            conditionLabel.heightAnchor.constraint(equalToConstant: 28),
            conditionLabelWidthConstraint
        ])
    }
    
    private func animateOfferImage() {
        offerImage.layer.removeAnimation(forKey: "offerImageAnimation")
        
        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.values = [
            offerImage.layer.position.y - 10,
            offerImage.layer.position.y,
            offerImage.layer.position.y - 10
        ]
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 1.5
        animation.repeatCount = Float.infinity
        
        offerImage.layer.add(animation, forKey: "offerImageAnimation")
    }
    
    private func updateGradients() {
        gradientView.layer.borderColor = ColorManager.shared.getOfferBorderColor(bounds: bounds)
        gradientView.backgroundColor = ColorManager.shared.getOfferBackgroundColor(for: traitCollection.userInterfaceStyle, primaryColor: primaryColor, bounds: bounds)
        offerLabel.textColor = ColorManager.shared.getOfferLabelColor(bounds: offerLabel.bounds)
    }
}
