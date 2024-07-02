//
//  DeliveryAddressCell.swift
//  IngredientMix
//

import UIKit

class DeliveryAddressCell: UITableViewCell {

    static let id = "DeliveryAddressCell"
    
    var placeName: String! {
        didSet {
            placeNameLabel.text = placeName
            setupUI()
        }
    }
    
    var goToAddressVCHandler: (() -> Void)!
    
    var isDefaultAdress: Bool = false {
        didSet {
            if isDefaultAdress {
                isDefaultAdressCheckBox.isChecked = true
            } else {
                isDefaultAdressCheckBox.isChecked = false
            }
        }
    }
    
    private lazy var isDefaultAdressCheckBox: CheckBox = {
        let checkbox = CheckBox()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.tintColor = ColorManager.shared.confirmingGreen
        return checkbox
    }()
    
    private lazy var placeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 600])
        return label
    }()
    
    private lazy var goToAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 500])
        button.setTitle("Details", for: .normal)
        button.setTitleColor(ColorManager.shared.label, for: .normal)
        button.setTitleColor(ColorManager.shared.label.withAlphaComponent(0.5), for: .highlighted)
        button.backgroundColor = ColorManager.shared.headerElementsColor
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(goToAddressButtonTapped), for: .touchUpInside)
        return button
    }()

    private func setupUI() {
        backgroundColor = ColorManager.shared.background
        
        addSubview(isDefaultAdressCheckBox)
        addSubview(placeNameLabel)
        addSubview(goToAddressButton)
        
        NSLayoutConstraint.activate([
            isDefaultAdressCheckBox.centerYAnchor.constraint(equalTo: centerYAnchor),
            isDefaultAdressCheckBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            isDefaultAdressCheckBox.heightAnchor.constraint(equalToConstant: Constants.checkboxSize),
            isDefaultAdressCheckBox.widthAnchor.constraint(equalToConstant: Constants.checkboxSize),
            
            placeNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeNameLabel.leadingAnchor.constraint(equalTo: isDefaultAdressCheckBox.trailingAnchor, constant: 32),
            placeNameLabel.trailingAnchor.constraint(equalTo: goToAddressButton.leadingAnchor, constant: -32),
            
            goToAddressButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            goToAddressButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            goToAddressButton.heightAnchor.constraint(equalToConstant: 40),
            goToAddressButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc
    private func goToAddressButtonTapped() {
        goToAddressVCHandler()
    }
    
}
