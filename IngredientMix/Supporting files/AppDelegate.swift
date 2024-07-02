//
//  AppDelegate.swift
//  IngredientMix
//

import UIKit
import Firebase
import FirebaseMessaging
import CoreData
import GoogleMaps

@main

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        GMSServices.provideAPIKey("YOUR_API_KEY")
        
        FirebaseApp.configure()
        registerForPushNotifications(application)
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        do {
            try CoreDataManager.shared.saveContext()
        } catch {
            ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Attempt to save the context when the application terminates."])
        }
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }


}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM Token: \(token)")
        // need to save token
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("Notification received with info: \(userInfo)")
        
        completionHandler()
    }
}
