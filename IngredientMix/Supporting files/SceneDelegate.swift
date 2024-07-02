//
//  SceneDelegate.swift
//  IngredientMix
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let tabBarVC = TabBarVC()
        tabBarVC.initialSetup(with: window.frame)
        
//        let initialVC: UIViewController
//        
//        if UserManager.shared.isUserLoggedIn() {
//            let tabBarVC = TabBarVC()
//            tabBarVC.initialSetup(with: window.frame)
//            initialVC = tabBarVC
//        } else {
//            initialVC = InitialVC()
//        }
        
        window.rootViewController = tabBarVC
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }


}

