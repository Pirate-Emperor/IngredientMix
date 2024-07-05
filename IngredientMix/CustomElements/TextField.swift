//
//  TextField.swift
//  IngredientMix
//

import UIKit

final class TextField: UITextField {

    var paddingTop: CGFloat = 8
    var paddingLeft: CGFloat = 16
    var paddingBottom: CGFloat = 8
    var paddingRight: CGFloat = 16
    
    weak var associatedLabel: UILabel?
    
    private let normalColor = ColorManager.shared.regularFieldBorderColor
    private let warningColor = ColorManager.shared.warningRed.cgColor
    
    var isInWarning: Bool = false {
        didSet {
            updateBorder()
            updateLabelColor()
        }
    }
    
    private func updateBorder() {
        layer.borderColor = isInWarning ? warningColor : normalColor
        layer.borderWidth = isInWarning ? 1 : 0.5
    }
    
    private func updateLabelColor() {
        associatedLabel?.textColor = isInWarning ? ColorManager.shared.warningRed : ColorManager.shared.labelGray
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight))
        return insetBounds
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight))
        return insetBounds
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = bounds.inset(by: UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight))
        return insetBounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 22
        layer.borderWidth = 0.5
        layer.borderColor = normalColor
        backgroundColor = ColorManager.shared.regularFieldColor
        tintColor = ColorManager.shared.orange
        textColor = ColorManager.shared.label
        font = UIFont.systemFont(ofSize: 17)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
