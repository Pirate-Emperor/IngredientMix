//
//  NSString + Extention.swift
//  IngredientMix
//

import UIKit

extension NSString {
    func width(withFont font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: attributes)
        return size.width
    }
}
