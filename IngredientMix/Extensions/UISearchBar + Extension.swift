//
//  UISearchBar + Extension.swift
//  IngredientMix
//

import UIKit

extension UISearchBar {
    
    func updateHeight(to height: CGFloat, radius: CGFloat = 8.0) {
        let image: UIImage? = UIImage.imageWithColor(color: UIColor.clear, size: CGSize(width: 1, height: height))
        setSearchFieldBackgroundImage(image, for: .normal)
        for subview in self.subviews {
            for subSubViews in subview.subviews {
                if #available(iOS 13.0, *) {
                    for child in subSubViews.subviews {
                        if let textField = child as? UISearchTextField {
                            textField.layer.cornerRadius = radius
                            textField.clipsToBounds = true
                        }
                    }
                    continue
                }
                if let textField = subSubViews as? UITextField {
                    textField.layer.cornerRadius = radius
                    textField.clipsToBounds = true
                }
            }
        }
    }
    
    func setPlaceholderFont(_ font: UIFont) {
        if let textField = self.value(forKey: "searchField") as? UITextField {
            let placeholder = textField.placeholder ?? ""
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.font: font]
            )
        }
    }
    
    func setPadding(_ padding: CGFloat, on side: sideOfSearchBar) {
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        paddingView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        paddingView.widthAnchor.constraint(equalToConstant: padding).isActive = true
        
        switch side {
        case .right:
            searchTextField.rightView = paddingView
        case .left:
            searchTextField.leftView = paddingView
        }
    }
    
    enum sideOfSearchBar {
    case right, left
    }

}

