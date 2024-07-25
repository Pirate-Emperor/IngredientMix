//
//  ColorManager.swift
//  IngredientMix
//

import UIKit

final class ColorManager {
    
    static let shared = ColorManager()
    
    private init() {}
    
    // MARK: - UI element colors
    
    let background = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.063, green: 0.063, blue: 0.063, alpha: 1)
            : UIColor.white
    }
    
    let label = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.883, green: 0.883, blue: 0.883, alpha: 1)
            : UIColor(red: 0.118, green: 0.118, blue: 0.118, alpha: 1)
    }
    
    let labelGray = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.518, green: 0.518, blue: 0.518, alpha: 1)
            : UIColor.darkGray
    }
    
    let headerElementsColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.105, green: 0.105, blue: 0.105, alpha: 1)
            : UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }
    
    let translucentBackground = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.4)
            : UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 0.4)
    }
    
    let regularButtonColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.172, green: 0.172, blue: 0.172, alpha: 1)
            : UIColor(red: 0.117, green: 0.117, blue: 0.117, alpha: 1)
    }
    
    let regularFieldColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1)
            : .white
    }
    
    let lightGraySectionColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.105, green: 0.105, blue: 0.105, alpha: 1)
            : UIColor(red: 0.985, green: 0.985, blue: 0.985, alpha: 1)
    }
    
    let regularFieldBorderColor = UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 0.3).cgColor
    
    let confirmingGreen = UIColor(red: 0.476, green: 0.894, blue: 0.409, alpha: 1)
    let warningOrange = UIColor(red: 0.992, green: 0.592, blue: 0.196, alpha: 1)
    let warningRed = UIColor(red: 0.92, green: 0.23, blue: 0.35, alpha: 1.00)
    
    let orderVC_SectionColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.105, green: 0.105, blue: 0.105, alpha: 1)
            : UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }
    
    // MARK: - Initial screan colors
    
    let initialVC_background = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.063, green: 0.063, blue: 0.063, alpha: 1)
        : UIColor(red: 0.705, green: 0.9, blue: 0.76, alpha: 1)
    }
    
    let initialVC_loginButtonColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
        : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
    }
    
    let initialVC_createAccountButtonColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
            : UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    }
    
    let initialVC_continueAsGuestButtonColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    let login_secondaryButtonColor = UIColor(red: 0.451, green: 0.510, blue: 0.794, alpha: 1)
    
    // MARK: - Offer cell colors
    
    let offerCell_BorderSecondaryColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1)
            : UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    let offerCell_BackgroundSecondaryColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1)
            : UIColor.white
    }
    
    // MARK: - Menu page colors
    
    let dishCell_FavoriteButtonColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.2)
            : UIColor.white.withAlphaComponent(0.8)
    }
    
    // MARK: - Dish page colors
    
    let dishVC_addItemBlockColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.2)
            : UIColor.black
    }
    
    let dishVC_addToCartButtonColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1)
            : UIColor.white
    }
    
    // MARK: - Cart page colors
    
    let cart_promoCodeViewColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.105, green: 0.105, blue: 0.105, alpha: 1)
            : UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }
    
    let cart_applyCodeButtonColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.882, green: 0.882, blue: 0.882, alpha: 1)
            : UIColor(red: 0.117, green: 0.117, blue: 0.117, alpha: 1)
    }
    
    let cart_billDetailsViewColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.078, green: 0.078, blue: 0.078, alpha: 1)
            : UIColor(red: 0.972, green: 0.972, blue: 0.972, alpha: 1)
    }
    
    let cartCell_amountBlockColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.117, green: 0.117, blue: 0.117, alpha: 1)
            : UIColor(red: 0.882, green: 0.882, blue: 0.882, alpha: 1)
    }
    
    // MARK: - Payment page colors
    
    let payment_secondaryButtonColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1)
            : UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1)
    }
    
    let payment_sectionColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.105, green: 0.105, blue: 0.105, alpha: 1)
            : UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }
    
    let payment_totalAmountSection = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1)
            : UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }
    
    let payment_placeOrderButtonColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.243, green: 0.243, blue: 0.243, alpha: 1)
            : UIColor(red: 0.117, green: 0.117, blue: 0.117, alpha: 1)
    }
    
    // MARK: - Primary colors
    
    let gold = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.848, green: 0.678, blue: 0.405, alpha: 1)
            : UIColor(red: 0.898, green: 0.878, blue: 0.705, alpha: 1)
    }

    let green = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.476, green: 0.894, blue: 0.409, alpha: 1)
            : UIColor(red: 0.776, green: 0.894, blue: 0.709, alpha: 1)
    }

    let indigo = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.451, green: 0.510, blue: 0.794, alpha: 1)
            : UIColor(red: 0.701, green: 0.760, blue: 0.894, alpha: 1)
    }

    let mint = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.305, green: 0.901, blue: 0.560, alpha: 1)
            : UIColor(red: 0.705, green: 0.901, blue: 0.760, alpha: 1)
    }

    let teal = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.459, green: 0.801, blue: 0.801, alpha: 1)
            : UIColor(red: 0.709, green: 0.901, blue: 0.901, alpha: 1)
    }

    let sandy = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.902, green: 0.677, blue: 0.517, alpha: 1)
            : UIColor(red: 0.952, green: 0.827, blue: 0.717, alpha: 1)
    }

    let lavender = UIColor { (traitCollection: UITraitCollection) -> UIColor in
        return traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.855, green: 0.697, blue: 0.712, alpha: 1)
            : UIColor(red: 0.905, green: 0.847, blue: 0.862, alpha: 1)
    }
    
    let orange = UIColor(red: 0.992, green: 0.592, blue: 0.196, alpha: 1)
    
    // MARK: - Color methods
    
    // Returns a sequence of colors where each new color does not repeat the previous three
    func getColors(_ quantity: Int) -> [UIColor] {
        var colors: [UIColor] = []
        var previousColors: [UIColor] = []
        let tileColors: [UIColor] = [gold, green, indigo, mint, teal, sandy, lavender]
        
        for _ in 0..<quantity {
            var newColor: UIColor
            repeat {
                newColor = tileColors.randomElement()!
            } while previousColors.contains(newColor)
            
            colors.append(newColor)
            previousColors.append(newColor)
            if previousColors.count > 3 {
                previousColors.removeFirst()
            }
        }
        
        return colors
    }
    
    func getRandomColor() -> UIColor {
        let colors = [gold, green, indigo, mint, teal, sandy, lavender]
        return colors.randomElement()!
    }
    
    func getOfferLabelColor(bounds: CGRect) -> UIColor? {
        let colors = [label.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
        return getGradientColor(bounds: bounds, colors: colors, parameter: .vertical)
    }

    func getOfferBorderColor(bounds: CGRect) -> CGColor? {
        let colors = [offerCell_BorderSecondaryColor.cgColor, UIColor.clear.cgColor]
        return getGradientColor(bounds: bounds, colors: colors, parameter: .forOfferBorder)?.cgColor
    }
    
    func getOfferBackgroundColor(for theme: UIUserInterfaceStyle, primaryColor: UIColor, bounds: CGRect) -> UIColor? {
        let colors = [offerCell_BackgroundSecondaryColor.cgColor, primaryColor.cgColor]
        if theme == .dark {
            return getGradientColor(bounds: bounds, colors: colors, parameter: .forOfferBackDark)
        }
        return getGradientColor(bounds: bounds, colors: colors, parameter: .forOfferBackLight)
    }
    
    private func getGradientColor(bounds: CGRect, colors: [CGColor], parameter: GradientParameters) -> UIColor? {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        
        switch parameter {
        case .horizontal:
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        case .vertical:
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .forOfferBackLight:
            gradient.startPoint = CGPoint(x: 0.1, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: cos(0.1))
        case .forOfferBackDark:
            gradient.startPoint = CGPoint(x: 0.2, y: 0.7)
            gradient.endPoint = CGPoint(x: 1, y: 1)
        case .forOfferBorder:
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.7, y: sin(20.0 * .pi / 130.0))
        }
        
        UIGraphicsBeginImageContext(gradient.bounds.size)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image!)
    }
    
    enum GradientParameters {
        case horizontal
        case vertical
        case forOfferBackLight
        case forOfferBackDark
        case forOfferBorder
    }
    
}

// MARK: - AppColor Enum

enum AppColor {
    case background
    case label
    case labelGray
    case headerElementsColor
    case tabBarBackground
    case regularButtonColor
    case offerCellBorderSecondaryColor
    case offerCellBackgroundSecondaryColor
    case dishCellFavoriteButtonColor
    case dishVCAddItemBlockColor
    case dishVCAddToCartButtonColor
    case cartPromoCodeFieldColor
    case cartApplyCodeButtonColor
    case cartBillDetailsViewColor
    case cartCellAmountBlockColor
    case gold
    case green
    case indigo
    case mint
    case teal
    case sandy
    case lavender
    case orange
    
    func color(for traitCollection: UITraitCollection) -> UIColor {
        switch self {
        case .background:
            return ColorManager.shared.background.resolvedColor(with: traitCollection)
        case .label:
            return ColorManager.shared.label.resolvedColor(with: traitCollection)
        case .labelGray:
            return ColorManager.shared.labelGray.resolvedColor(with: traitCollection)
        case .headerElementsColor:
            return ColorManager.shared.headerElementsColor.resolvedColor(with: traitCollection)
        case .tabBarBackground:
            return ColorManager.shared.translucentBackground.resolvedColor(with: traitCollection)
        case .regularButtonColor:
            return ColorManager.shared.regularButtonColor.resolvedColor(with: traitCollection)
        case .offerCellBorderSecondaryColor:
            return ColorManager.shared.offerCell_BorderSecondaryColor.resolvedColor(with: traitCollection)
        case .offerCellBackgroundSecondaryColor:
            return ColorManager.shared.offerCell_BackgroundSecondaryColor.resolvedColor(with: traitCollection)
        case .dishCellFavoriteButtonColor:
            return ColorManager.shared.dishCell_FavoriteButtonColor.resolvedColor(with: traitCollection)
        case .dishVCAddItemBlockColor:
            return ColorManager.shared.dishVC_addItemBlockColor.resolvedColor(with: traitCollection)
        case .dishVCAddToCartButtonColor:
            return ColorManager.shared.dishVC_addToCartButtonColor.resolvedColor(with: traitCollection)
        case .cartPromoCodeFieldColor:
            return ColorManager.shared.cart_promoCodeViewColor.resolvedColor(with: traitCollection)
        case .cartApplyCodeButtonColor:
            return ColorManager.shared.cart_applyCodeButtonColor.resolvedColor(with: traitCollection)
        case .cartBillDetailsViewColor:
            return ColorManager.shared.cart_billDetailsViewColor.resolvedColor(with: traitCollection)
        case .cartCellAmountBlockColor:
            return ColorManager.shared.cartCell_amountBlockColor.resolvedColor(with: traitCollection)
        case .gold:
            return ColorManager.shared.gold.resolvedColor(with: traitCollection)
        case .green:
            return ColorManager.shared.green.resolvedColor(with: traitCollection)
        case .indigo:
            return ColorManager.shared.indigo.resolvedColor(with: traitCollection)
        case .mint:
            return ColorManager.shared.mint.resolvedColor(with: traitCollection)
        case .teal:
            return ColorManager.shared.teal.resolvedColor(with: traitCollection)
        case .sandy:
            return ColorManager.shared.sandy.resolvedColor(with: traitCollection)
        case .lavender:
            return ColorManager.shared.lavender.resolvedColor(with: traitCollection)
        case .orange:
            return ColorManager.shared.orange
        }
    }
}
