//
//  ProfileMenuCell.swift
//  IngredientMix
//

import UIKit

final class ProfileMenuCell: UITableViewCell {

    static let id = "ProfileMenuCell"
    
    var menuItemName: String! {
        didSet {
            menuItemNameLabel.text = menuItemName
            setupUI()
        }
    }
    
    var extraParameter: String? {
        didSet {
            extraParameterLabel.text = extraParameter
        }
    }
    
    private lazy var menuItemNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 600])
        return label
    }()
    
    private lazy var extraParameterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 450])
        label.textAlignment = .right
        return label
    }()

    private func setupUI() {
        backgroundColor = ColorManager.shared.background
        addSubview(menuItemNameLabel)
        addSubview(extraParameterLabel)
        NSLayoutConstraint.activate([
            menuItemNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            menuItemNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            menuItemNameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -24),
            extraParameterLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            extraParameterLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            extraParameterLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -40)
        ])
    }
    
}
