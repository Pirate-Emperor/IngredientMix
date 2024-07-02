//
//  PreloaderView.swift
//  IngredientMix
//

import UIKit

final class PreloaderView: UIView {
    
    private lazy var preloaderMessage: UILabel = {
        let frame = CGRect(x: 0, y: 8, width: Int(frame.width), height: 32)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.textColor = ColorManager.shared.label
        label.text = "Downloading menu..."
        label.font = UIFont(name: "Raleway", size: 16)
        label.numberOfLines = 1
        label.layer.shadowOffset = CGSize(width: 3, height: 3)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        return label
    }()
    
    private lazy var preloader: Preloader = {
        let view = Preloader(parentFrame: frame, size: 60)
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowOpacity = 0.7
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 3
        return view
    }()
    
    private lazy var downloadErrorImageView: UIImageView = {
        let frame = CGRect(x: Int(frame.width / 2 - 30), y: Int(frame.height / 2 - 36), width: 60, height: 60)
        let image = UIImage(systemName: "multiply")
        let view  = UIImageView(frame: frame)
        view.image = image
        view.tintColor = ColorManager.shared.label.withAlphaComponent(0.5)
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowOpacity = 0.7
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 3
        view.isHidden = true
        return view
    }()
    
    private lazy var reloadButton: UIButton = {
        let frame = CGRect(x: Int(frame.width / 2 - 48), y: Int(frame.height - 40), width: 96, height: 32)
        let button = UIButton(frame: frame)
        button.backgroundColor = ColorManager.shared.headerElementsColor
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(ColorManager.shared.label, for: .normal)
        button.setTitleColor(ColorManager.shared.label.withAlphaComponent(0.5), for: .highlighted)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(reloadButtonTaped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private var isLoadingError = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startLoadingAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 16
        addSubview(preloaderMessage)
        addSubview(preloader)
        addSubview(downloadErrorImageView)
        addSubview(reloadButton)
    }
    
    @objc
    private func reloadButtonTaped() {
        switchState()
    }
    
    func switchState() {
        if isLoadingError {
            preloaderMessage.text = "Downloading menu..."
            preloader.isHidden.toggle()
            reloadButton.isHidden.toggle()
            downloadErrorImageView.isHidden.toggle()
            isLoadingError.toggle()
        } else {
            preloaderMessage.text = "Ups. Trouble with downloading..."
            preloader.isHidden.toggle()
            reloadButton.isHidden.toggle()
            downloadErrorImageView.isHidden.toggle()
            isLoadingError.toggle()
        }
    }
    
    func startLoadingAnimation() {
        preloader.startAnimation(delay: 0.04, replicates: 16)
    }
    
}
