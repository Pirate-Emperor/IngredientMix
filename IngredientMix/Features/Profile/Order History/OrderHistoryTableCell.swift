//
//  OrderHistoryTableCell.swift
//  IngredientMix
//

import UIKit

final class OrderHistoryTableCell: UITableViewCell {

    static let id = "OrderHistoryTableCell"
    
    private lazy var orderStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var orderDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var orderAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.shared.label
        return imageView
    }()

    private func setupUI() {
        backgroundColor = ColorManager.shared.background
        
        addSubview(orderStatusLabel)
        addSubview(orderDateLabel)
        addSubview(orderAmountLabel)
        addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            orderStatusLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10),
            orderStatusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            
            orderDateLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            orderDateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            orderDateLabel.trailingAnchor.constraint(equalTo: orderAmountLabel.leadingAnchor, constant: -16),
            
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            
            orderAmountLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            orderAmountLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            orderAmountLabel.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func configureCell(withStatus status: String, date: String, amount: String) {
        orderStatusLabel.text = status
        orderDateLabel.text = date
        orderAmountLabel.text = amount
        setupUI()
    }
    
}
