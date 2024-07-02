//
//  TabBarVC.swift
//  IngredientMix
//

import UIKit

final class TabBarVC: UIViewController {
    
    private var cartStatusObserver: CartStatusObserver?
    
    lazy var tabBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = tabBarHeight / 2
        view.backgroundColor = ColorManager.shared.translucentBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 30
        return view
    }()
    
    private lazy var blurEffect: UIVisualEffectView = {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect(style: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = tabBarHeight / 2
        view.clipsToBounds = true
        view.effect = blur
        return view
    }()
    
    private lazy var tabStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private lazy var menuTabButton: TabBarButton = {
        let button = TabBarButton()
        button.addTarget(self, action: #selector(tabDidTaped), for: .touchUpInside)
        button.tag = 0
        button.setLayout(for: tabSize)
        button.setName("Menu")
        button.initSelection()
        return button
    }()
    
    private lazy var favoriteTabButton: TabBarButton = {
        let button = TabBarButton()
        button.addTarget(self, action: #selector(tabDidTaped), for: .touchUpInside)
        button.tag = 1
        button.setLayout(for: tabSize)
        button.setName("Favorite")
        return button
    }()
    
    private lazy var cartTabButton: TabBarButton = {
        let button = TabBarButton()
        button.addTarget(self, action: #selector(tabDidTaped), for: .touchUpInside)
        button.tag = 2
        button.setLayout(for: tabSize)
        button.setName("Cart")
        return button
    }()
    
    private lazy var profileTabButton: TabBarButton = {
        let button = TabBarButton()
        button.addTarget(self, action: #selector(tabDidTaped), for: .touchUpInside)
        button.tag = 3
        button.setLayout(for: tabSize)
        button.setName("Profile")
        return button
    }()
    
    private lazy var activeTabBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = CGSize(width: tabSize, height: tabSize)
        view.layer.cornerRadius = tabSize / 2
        view.backgroundColor = .white.withAlphaComponent(0.9)
        return view
    }()
    
    private var activeTabBackgroundViewCenterXConstraint: NSLayoutConstraint?
    
    private var tabBarIsVisible = true
    
    private var cartIsEmpty = true {
        didSet {
            updateCartIcon()
        }
    }
    
    private lazy var tabs = [menuTabButton, favoriteTabButton, cartTabButton, profileTabButton]
    
    private var selectedIndex: Int = 0
    private var previousIndex: Int = 0
    
    private let tabBarHeight: CGFloat = 72
    private let tabBarMargin: CGFloat = 40
    private let tabMargin: CGFloat = 6
    private var tabSize: CGFloat { tabBarHeight - tabMargin * 2 }
    
    private var viewControllers = [UIViewController]()
    
    static let menuVC = MenuTabVC()
    static let favoriteVC = FavoriteTabVC()
    
    static let cartNavVC: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: CartTabVC())
        navigationController.navigationBar.tintColor = ColorManager.shared.label
        return navigationController
    }()
    
    static let profileNavVC: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: ProfileTabVC())
        navigationController.navigationBar.tintColor = ColorManager.shared.label
        return navigationController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers.append(TabBarVC.menuVC)
        viewControllers.append(TabBarVC.favoriteVC)
        viewControllers.append(TabBarVC.cartNavVC)
        viewControllers.append(TabBarVC.profileNavVC)
        
        tabs[selectedIndex].isSelected = true
        
        setupUI()
        setupConstraints()
                
        setupCartStatusObserver()
        
        TabBarVC.cartNavVC.delegate = self
        TabBarVC.profileNavVC.delegate = self
    }
    
    func initialSetup(with frame: CGRect) {
        let menuVC = TabBarVC.menuVC
        menuVC.view.frame = frame
        menuVC.didMove(toParent: self)
        addChild(menuVC)
        view.addSubview(menuVC.view)
        view.bringSubviewToFront(tabBarView)
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        view.addSubview(tabBarView)
        tabBarView.addSubview(blurEffect)
        tabBarView.addSubview(activeTabBackgroundView)
        tabBarView.addSubview(tabStack)
        tabStack.addArrangedSubview(menuTabButton)
        tabStack.addArrangedSubview(favoriteTabButton)
        tabStack.addArrangedSubview(cartTabButton)
        tabStack.addArrangedSubview(profileTabButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tabBarView.heightAnchor.constraint(equalToConstant: tabBarHeight),
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: tabBarMargin),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -tabBarMargin),
            tabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarMargin),
            
            blurEffect.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            blurEffect.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor),
            blurEffect.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor),
            blurEffect.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor),
            
            activeTabBackgroundView.centerYAnchor.constraint(equalTo: tabBarView.centerYAnchor),
            activeTabBackgroundView.heightAnchor.constraint(equalToConstant: tabSize),
            activeTabBackgroundView.widthAnchor.constraint(equalToConstant: tabSize),
            
            tabStack.topAnchor.constraint(equalTo: tabBarView.topAnchor, constant: tabMargin),
            tabStack.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor, constant: tabMargin),
            tabStack.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor, constant: -tabMargin),
            tabStack.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor, constant: -tabMargin)
        ])
        
        activeTabBackgroundViewCenterXConstraint = activeTabBackgroundView.centerXAnchor.constraint(equalTo: menuTabButton.centerXAnchor)
        activeTabBackgroundViewCenterXConstraint?.isActive = true
        
        tabs.forEach { tab in
            tab.widthAnchor.constraint(equalToConstant: tabSize).isActive = true
        }
    }
    
    private func setupCartStatusObserver() {
        CartStatusObserver.shared.cartStatusDidChange = { [weak self] value in
            self?.cartIsEmpty = value
        }
        
        do {
            try CartStatusObserver.shared.observeCartStatus()
        } catch {
            ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when trying to run the cart fullness monitor."])
            UserNotification.show(for: error, in: self)
        }
    }
    
    private func updateCartIcon() {
        if cartIsEmpty {
            cartTabButton.setIcon(image: UIImage(named: "Cart"))
        } else {
            if selectedIndex == 2 {
                cartTabButton.setIcon(image: UIImage(named: "Cart-full-active"))
            } else if previousIndex == 2 {
                cartTabButton.setIcon(image: UIImage(named: "Cart-full-passive"))
            } else if selectedIndex == 0 && previousIndex == 0 {
                cartTabButton.setIcon(image: UIImage(named: "Cart-full-passive"))
            }
        }
    }
    
    private func updateBackgroundViewConstraint(for activeTab: TabBarButton) {
        activeTabBackgroundViewCenterXConstraint?.isActive = false
        activeTabBackgroundViewCenterXConstraint = activeTabBackgroundView.centerXAnchor.constraint(equalTo: activeTab.centerXAnchor)
        activeTabBackgroundViewCenterXConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - actions
extension TabBarVC {
    
    @objc
    private func tabDidTaped(_ sender: TabBarButton) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first else { return }
        
        let newIndex = sender.tag
        guard newIndex != selectedIndex else { return }
        
        previousIndex = selectedIndex
        selectedIndex = newIndex
        
        tabs[previousIndex].makeUnselected()
        tabs[newIndex].makeSelected()
        
        if newIndex == 2 || previousIndex == 2 {
            updateCartIcon()
        }
        
        updateBackgroundViewConstraint(for: sender)
        
        let previousVC = viewControllers[previousIndex]
        let currentVC = viewControllers[newIndex]
        
        let isMovingRight = newIndex > previousIndex
        let offScreenOffset = window.frame.width * (isMovingRight ? 1 : -1)
        
        currentVC.view.frame = window.frame.offsetBy(dx: offScreenOffset, dy: 0)
        addChild(currentVC)
        view.addSubview(currentVC.view)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.4, animations: {
            previousVC.view.frame = previousVC.view.frame.offsetBy(dx: -offScreenOffset, dy: 0)
            currentVC.view.frame = window.frame
        }) { _ in
            previousVC.willMove(toParent: nil)
            previousVC.view.removeFromSuperview()
            previousVC.removeFromParent()
            currentVC.didMove(toParent: self)
        }

        view.bringSubviewToFront(tabBarView)
    }

    
    func hideTabBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.tabBarView.transform = CGAffineTransform(translationX: 0, y: 115)
            self.tabBarView.alpha = 0
        }
        tabBarIsVisible = false
    }
    
    func showTabBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
            self.tabBarView.transform = .identity
            self.tabBarView.alpha = 1
        }
        tabBarIsVisible = true
    }

}

// MARK: - UINavigationControllerDelegate

extension TabBarVC: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isRootVC = viewController === navigationController.viewControllers.first
        
        if isRootVC {
            showTabBar()
        } else {
            if tabBarIsVisible {
                hideTabBar()
            }
        }
    }
    
}
