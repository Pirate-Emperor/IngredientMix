//
//  UserManager.swift
//  IngredientMix
//

import UIKit
import FirebaseAuth

final class UserManager {
    
    static let shared = UserManager()

    private init() {}

    private let coreDataManager = CoreDataManager.shared
    private let firebaseManager = FirebaseManager.shared
    
    private var cachedAvatarImage: UIImage?
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    func getUserID() -> String {
        Auth.auth().currentUser?.uid ?? "Guest"
    }
    
    func getUserEntity() throws -> UserEntity? {
        return try coreDataManager.fetchUser()
    }
    
    func authenticateUser(email: String, password: String) async throws {
        let user = try await firebaseManager.authenticateUser(email: email, password: password)
        try coreDataManager.saveUser(user)
        
        if let avatarURL = user.photoURL?.absoluteString {
            let avatarData = try await firebaseManager.downloadImage(from: avatarURL)
            try coreDataManager.updateUserAvatar(with: avatarData)
            cachedAvatarImage = UIImage(data: avatarData)
        }
        
        do {
            try await OrderManager.shared.fetchOrderHistory()
        } catch {
            throw FirebaseManagerError.firestoreDataWasNotReceived(error)
        }
    }
    
    func registerUser(name: String, email: String, password: String) async throws {
        let user = try await firebaseManager.registerUser(email: email, password: password)
        try coreDataManager.saveUser(user)
        
        if !name.isEmpty {
            try await setUserName(name)
        }
    }
    
    func logoutUser() throws {
        try Auth.auth().signOut()
        try coreDataManager.deleteUser()
        try coreDataManager.deleteAllOrders()
        cachedAvatarImage = nil
    }
    
    func setUserName(_ name: String) async throws {
        try await firebaseManager.setDisplayName(name)
        try coreDataManager.setDisplayName(name)
    }
    
    func updateEmail(to newEmail: String, withPassword password: String) async throws {
        try await firebaseManager.updateEmail(to: newEmail, withPassword: password)
        try coreDataManager.updateEmail(newEmail)
    }
    
    func updatePassword(currentPassword: String, to newPassword: String) async throws {
        try await firebaseManager.updatePassword(currentPassword: currentPassword, to: newPassword)
    }
    
    func getUserAvatar() -> UIImage? {
        if let cachedImage = cachedAvatarImage {
            return cachedImage
        } else if let userEntity = try? coreDataManager.fetchUser(),
                  let avatarData = userEntity.avatar {
            let image = UIImage(data: avatarData)
            cachedAvatarImage = image
            return image
        } else {
            return UIImage(named: "Guest")
        }
    }
    
    func uploadUserAvatar(_ image: UIImage) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let avatarURL = try await firebaseManager.uploadUserAvatar(imageData)
        try coreDataManager.updateUserAvatar(avatarData: imageData, avatarURL: avatarURL.absoluteString)
        cachedAvatarImage = image
    }

    func deleteUserAvatar() async throws {
        try await firebaseManager.deleteUserAvatar()
        try coreDataManager.updateUserAvatar(avatarData: nil, avatarURL: nil)
        cachedAvatarImage = nil
    }
}
