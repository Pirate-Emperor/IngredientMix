//
//  TabBarButton.swift
//  IngredientMix
//

import UIKit

class TabBarButton: UIButton {
    
    private let icon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = .white
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private var buttonSize = CGFloat()
    private lazy var iconFrame_selected = CGRect(x: 0, y: 0, width: buttonSize / 2, height: buttonSize / 2)
    private lazy var iconFrame_unselected = CGRect(x: 0, y: 0, width: buttonSize / 2.7, height: buttonSize / 2.7)
    private lazy var iconCenterPoint_selected = CGPoint(x: buttonSize / 2, y: buttonSize / 2)
    private lazy var iconCenterPoint_unselected = CGPoint(x: buttonSize / 2, y: buttonSize / 2.8)
    private lazy var labelFrame = CGRect(x: 0, y: 0, width: buttonSize, height: 20)
    private lazy var labelCenterPoint = CGPoint(x: buttonSize / 2, y: buttonSize - 15)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(icon)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout(for size: CGFloat) {
        buttonSize = size
        layer.cornerRadius = size / 2
        icon.frame = iconFrame_unselected
        icon.center = iconCenterPoint_unselected
        label.frame = labelFrame
        label.center = labelCenterPoint
    }
    
    func setName(_ name: String) {
        icon.image = UIImage(named: name)
        label.text = name
    }
    
    func initSelection() {
        icon.frame = iconFrame_selected
        icon.center = iconCenterPoint_selected
        icon.tintColor = .black
        label.isHidden = true
    }
    
    func makeSelected() {
        isSelected = true
        label.isHidden = true
        icon.tintColor = .black
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) { [self] in
            icon.frame = iconFrame_selected
            icon.center = iconCenterPoint_selected
        }
    }
    
    func makeUnselected() {
        isSelected = false
        label.isHidden = false
        icon.tintColor = .white
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) { [self] in
            icon.frame = iconFrame_unselected
            icon.center = iconCenterPoint_unselected
        }
    }
    
    func setIcon(image: UIImage?) {
        icon.image = image
    }
}
