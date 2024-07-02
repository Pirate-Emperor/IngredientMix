//
//  UIFont + Extension.swift
//  IngredientMix
//

import UIKit

extension UIFont {
    static func getVariableVersion(of fontName: String, size: CGFloat, axis: [Int: Int] = [:]) -> UIFont {
        let descriptor = UIFontDescriptor(fontAttributes: [.name: fontName, kCTFontVariationAttribute as UIFontDescriptor.AttributeName: axis])
        let variableFont = UIFont(descriptor: descriptor, size: size)
        return variableFont
    }
}
