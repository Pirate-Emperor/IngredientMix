//
//  RadioButton.swift
//  IngredientMix
//

import UIKit

class RadioButton: UIButton {
    
    var alternateButton:Array<RadioButton>?
    
    private lazy var selectedStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.label
        view.layer.cornerRadius = 6
        view.alpha = isSelected ? 1 : 0
        return view
    }()
    
    weak var associatedLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.3).cgColor
        layer.masksToBounds = true
        
        tintColor = ColorManager.shared.background
        
        addSubview(selectedStateView)
        
        NSLayoutConstraint.activate([
            selectedStateView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedStateView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectedStateView.heightAnchor.constraint(equalToConstant: 12),
            selectedStateView.widthAnchor.constraint(equalTo: selectedStateView.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        unselectAlternateButtons()
        super.touchesBegan(touches, with: event)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if isSelected {
            layer.borderColor = ColorManager.shared.label.cgColor
        } else {
            layer.borderColor = ColorManager.shared.labelGray.cgColor
        }
    }
    
    func unselectAlternateButtons() {
        if alternateButton != nil {
            self.isSelected = true
            
            for button in alternateButton! {
                button.isSelected = false
            }
        } else {
            toggleButton()
        }
    }

    func toggleButton() {
        self.isSelected = !isSelected
    }
        
    override var isSelected: Bool {
        didSet {
            if isSelected {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
                    self.selectedStateView.alpha = 1
                }
                associatedLabel?.textColor = ColorManager.shared.label
                backgroundColor = ColorManager.shared.background
                layer.borderColor = ColorManager.shared.label.cgColor
            } else {
                selectedStateView.alpha = 0
                associatedLabel?.textColor = ColorManager.shared.labelGray
                backgroundColor = .white
                layer.borderColor = ColorManager.shared.labelGray.cgColor
            }
        }
    }
}
