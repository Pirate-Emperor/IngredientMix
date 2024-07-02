//
//  TagCell.swift
//  IngredientMix
//

import UIKit

final class TagCell: UICollectionViewCell {
    static let id = "TagCell"
    
    var tagDidTapped: ((String) -> Void)?
    
    lazy var tagButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitleColor(ColorManager.shared.background, for: .selected)
        button.titleLabel?.font = UIFont(name: "Raleway", size: 14)
        button.layer.borderWidth = 0.6
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.cornerRadius = bounds.height / 2
        button.addTarget(self, action: #selector(tagToggle), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tagButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func tagToggle(sender: UIButton) {
        guard let tag = sender.titleLabel?.text else { return }
        if !sender.isSelected {
            setSelected()
            tagDidTapped?(tag)
        }
    }
    
    func setSelected() {
        tagButton.layer.borderWidth = 0
        tagButton.backgroundColor = ColorManager.shared.label
        tagButton.isSelected = true
    }
    
    func setUnselected() {
        tagButton.layer.borderWidth = 0.6
        tagButton.backgroundColor = ColorManager.shared.background
        tagButton.isSelected = false
    }
}

