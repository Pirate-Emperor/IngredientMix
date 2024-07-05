//
//  SeparatorView.swift
//  IngredientMix
//

import UIKit

class SeparatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorManager.shared.labelGray.withAlphaComponent(0.2)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = ColorManager.shared.labelGray.withAlphaComponent(0.2)
    }
}
