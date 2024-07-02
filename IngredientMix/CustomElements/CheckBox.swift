//
//  CheckBox.swift
//  IngredientMix
//

import UIKit

final class CheckBox: UIButton {
    
    private let checkedImage = UIImage(systemName: "checkmark")! as UIImage
    
    private let normalColor = ColorManager.shared.labelGray.cgColor
    private let warningColor = ColorManager.shared.warningRed.cgColor
    
    var isChecked: Bool = false {
        didSet {
            setImage(isChecked ? checkedImage : nil, for: .normal)
            if isChecked {
                isInWarning = false
            }
        }
    }
    
    weak var associatedLabel: UILabel?
    
    var isInWarning: Bool = false {
        didSet {
            layer.borderColor = isInWarning ? warningColor : normalColor
            updateLabelColor()
        }
    }
    
    private func updateLabelColor() {
        associatedLabel?.textColor = isInWarning ? ColorManager.shared.warningRed : ColorManager.shared.labelGray
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = normalColor
        backgroundColor = ColorManager.shared.background
        tintColor = ColorManager.shared.orange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
