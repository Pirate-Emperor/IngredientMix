//
//  NavigationBarBackButtonView.swift
//  IngredientMix
//

import UIKit

final class NavigationBarButtonView: UIView {

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.headerButtonSize, height: Constants.headerButtonSize))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = ColorManager.shared.headerElementsColor
        layer.cornerRadius = Constants.headerButtonSize / 2
        isUserInteractionEnabled = true
        clipsToBounds = true
    }
    
    private func configureButton(withSystemName systemName: String, imageSize: CGSize, pointSize: CGFloat, weight: UIImage.SymbolWeight) {
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        let image = UIImage(systemName: systemName, withConfiguration: configuration)?
            .resized(to: imageSize)
            .withTintColor(ColorManager.shared.label, renderingMode: .alwaysOriginal)

        let buttonImageView = UIImageView(frame: CGRect(origin: .zero, size: imageSize))
        buttonImageView.image = image
        buttonImageView.center = center

        addSubview(buttonImageView)
    }
    
    func configureAsBackButton() {
        configureButton(withSystemName: "chevron.backward", imageSize: CGSize(width: 12, height: 16), pointSize: 20, weight: .semibold)
    }
    
    func configureAsPlusButton() {
        configureButton(withSystemName: "plus", imageSize: CGSize(width: 20, height: 20), pointSize: 20, weight: .regular)
    }
    
    func configureAsGeolocationButton() {
        let image = UIImage(named: "Pin")?.withTintColor(ColorManager.shared.label, renderingMode: .alwaysOriginal)
        let buttonImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 17, height: 20)))
        buttonImageView.image = image
        buttonImageView.center = center

        addSubview(buttonImageView)
    }
}

