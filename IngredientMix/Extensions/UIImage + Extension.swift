//
//  UIImage + Extension.swift
//  IngredientMix
//

import UIKit

extension UIImage {
    
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return image
    }
}

