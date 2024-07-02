//
//  FirebaseManager.swift
//  IngredientMix
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Network

enum FirebaseManagerError: Error {
    case noInternetConnection
    case invalidData
    case parseDataFailed
    case updateFailed(Error)
    case networkError(Error)
    case downloadImageFailed(Error)
    case uploadImageFailed(Error)
    case firestoreDataWasNotReceived(Error)
    case firestoreDataWasNotSaved(Error)
    
    case authenticationFailed
    case registrationFailed
    case userAlreadyExists
    case userNotFound

    case promoCodeNotFound
    case promoCodeExpired
    case promoCodeLimitReached
}

final class FirebaseManager {

    static let shared = FirebaseManager()

    private init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isConnectedToNetwork = (path.status == .satisfied)
        }
        networkMonitor.start(queue: networkQueue)
    }

    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    private let auth = Auth.auth()
    
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue.global(qos: .background)
    
    private(set) var isConnectedToNetwork: Bool = false
    
    private func checkConnection() throws {
        guard isConnectedToNetwork else { throw FirebaseManagerError.noInternetConnection }
    }
    
    func downloadImage(from storageURL: String) async throws -> Data {
        try checkConnection()
        
        let storageRef = storage.reference(forURL: storageURL)
        let maxImageSize: Int64 = 3 * 1024 * 1024 // 3MB

        do {
            let data = try await storageRef.data(maxSize: maxImageSize)
            return data
        } catch {
            throw FirebaseManagerError.networkError(error)
        }
    }
    
    func sendFeedback(message: String) async throws {
        try checkConnection()
        
        let userID: String
        if let currentUser = auth.currentUser {
            userID = currentUser.uid
        } else {
            userID = "guest"
        }
        
        let documentID = UUID().uuidString
        let feedbackDocument = firestore.collection("feedbacks").document(documentID)
        
        let feedbackData: [String: Any] = [
            "user": userID,
            "message": message,
            "date": Timestamp(date: Date())
        ]
        
        do {
            try await feedbackDocument.setData(feedbackData)
        } catch {
            throw FirebaseManagerError.firestoreDataWasNotSaved(error)
        }
    }
    
    func applyPromoCode(_ code: String) async throws -> (discountPercentage: Int, freeDelivery: Bool, expirationDate: Date) {
        let promoCodeRef = firestore.collection("promoCodes").document(code)
        
        do {
            let promoCodeSnapshot = try await promoCodeRef.getDocument()
            
            guard promoCodeSnapshot.exists else {
                throw FirebaseManagerError.promoCodeNotFound
            }

            guard let data = promoCodeSnapshot.data() else {
                throw FirebaseManagerError.invalidData
            }

            guard let usageLimit = data["usageLimit"] as? Int,
                  let usedCount = data["usedCount"] as? Int,
                  let expirationDate = (data["expirationDate"] as? Timestamp)?.dateValue() else {
                throw FirebaseManagerError.invalidData
            }

            let currentDate = Date()
            if expirationDate < currentDate {
                throw FirebaseManagerError.promoCodeExpired
            }

            if usedCount >= usageLimit {
                throw FirebaseManagerError.promoCodeLimitReached
            }

            _ = try await firestore.runTransaction { transaction, _ in
                let updatedUsedCount = usedCount + 1
                transaction.updateData(["usedCount": updatedUsedCount], forDocument: promoCodeRef)
                return nil
            }

            let discountPercentage = data["discountPercent"] as? Int ?? 0
            let freeDelivery = data["freeDelivery"] as? Bool ?? false

            return (discountPercentage, freeDelivery, expirationDate)

        } catch let error as FirebaseManagerError {
            throw error
        } catch {
            throw FirebaseManagerError.firestoreDataWasNotReceived(error)
        }
    }

    func saveNotificationToken(_ token: String) async throws {
        try checkConnection()
        
        let userID: String
        if let currentUser = auth.currentUser {
            userID = currentUser.uid
        } else {
            userID = "guest"
        }
        
        let tokenDocument = firestore.collection("userTokens").document(userID)
        
        let tokenData: [String: Any] = [
            "token": token,
            "date": Timestamp(date: Date())
        ]
        
        do {
            try await tokenDocument.setData(tokenData, merge: true)
            print("Notification token saved successfully")
        } catch {
            throw FirebaseManagerError.firestoreDataWasNotSaved(error)
        }
    }

    
    // MARK: - Menu methods

    func getMenu() async throws -> Menu {
        try checkConnection()
        
        let offersData = try await getFirestoreData("offers")
        let dishesData = try await getFirestoreData("menu")

        var offers: [Offer] = []
        var dishes: [Dish] = []
        
        try await withThrowingTaskGroup(of: Offer.self) { taskGroup in
            for offerData in offersData {
                taskGroup.addTask {
                    return try await self.createOffer(from: offerData)
                }
            }
            for try await offer in taskGroup {
                offers.append(offer)
            }
        }
        
        try await withThrowingTaskGroup(of: Dish.self) { taskGroup in
            for dishData in dishesData {
                taskGroup.addTask {
                    return try await self.createDish(from: dishData)
                }
            }
            for try await dish in taskGroup {
                dishes.append(dish)
            }
        }
        
        var menu = Menu(offers: offers, dishes: dishes)
        menu.tagsContainer.tags.insert("All", at: 0)

        return menu
    }
    
    func getLatestMenuVersionNumber() async throws -> String {
        try checkConnection()
        
        let documents = try await getFirestoreData("versions")
                
        guard let document = documents.first(where: { $0.documentID == "latest" }),
              let data = document.data(),
              let version = data["menu"] as? String
        else {
            throw FirebaseManagerError.invalidData
        }
        
        return version
    }
    
    // MARK: - User methods

    func authenticateUser(email: String, password: String) async throws -> User {
        try checkConnection()
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user
        } catch let error as NSError {
            if error.code == AuthErrorCode.networkError.rawValue {
                throw FirebaseManagerError.networkError(error)
            }
            throw FirebaseManagerError.authenticationFailed
        }
    }
  
    func registerUser(email: String, password: String) async throws -> User {
        try checkConnection()
        
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            return authResult.user
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw FirebaseManagerError.userAlreadyExists
            case AuthErrorCode.networkError.rawValue:
                throw FirebaseManagerError.networkError(error)
            default:
                throw FirebaseManagerError.registrationFailed
            }
        }
    }
    
    func setDisplayName(_ name: String) async throws {
        try checkConnection()
        
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseManagerError.userNotFound
        }
        
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.displayName = name
        
        do {
            try await changeRequest.commitChanges()
        } catch {
            throw FirebaseManagerError.updateFailed(error)
        }
    }
    
    func updateEmail(to newEmail: String, withPassword password: String) async throws {
        try checkConnection()
        
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseManagerError.userNotFound
        }
        
        let credential = EmailAuthProvider.credential(withEmail: currentUser.email ?? "", password: password)
        
        do {
            try await currentUser.reauthenticate(with: credential)
            try await currentUser.sendEmailVerification(beforeUpdatingEmail: newEmail)
            
        } catch {
            throw FirebaseManagerError.updateFailed(error)
        }
    }
    
    func updatePassword(currentPassword: String, to newPassword: String) async throws {
        try checkConnection()
        
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseManagerError.userNotFound
        }

        let credential = EmailAuthProvider.credential(withEmail: currentUser.email ?? "", password: currentPassword)

        do {
            try await currentUser.reauthenticate(with: credential)
            try await currentUser.updatePassword(to: newPassword)
        } catch {
            throw FirebaseManagerError.updateFailed(error)
        }
    }
    
    func uploadUserAvatar(_ avatarData: Data) async throws -> URL {
        try checkConnection()
        
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseManagerError.userNotFound
        }

        let storageRef = storage.reference().child("userAvatars/\(currentUser.uid)/avatar.jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            let _ = try await storageRef.putDataAsync(avatarData, metadata: metadata)
            let downloadURL = try await storageRef.downloadURL()
            
            let changeRequest = currentUser.createProfileChangeRequest()
            changeRequest.photoURL = downloadURL
            
            try await changeRequest.commitChanges()
            
            return downloadURL
        } catch {
            throw FirebaseManagerError.uploadImageFailed(error)
        }
    }
    
    func deleteUserAvatar() async throws {
        try checkConnection()
        
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseManagerError.userNotFound
        }
        
        let avatarRef = storage.reference().child("userAvatars/\(currentUser.uid)/avatar.jpg")
        
        try await avatarRef.delete()
    }
    
    // MARK: - Order methods
    
    func saveOrderToFirestore(_ order: OrderEntity) async throws {
        try checkConnection()
        
        guard let orderID = order.orderID?.uuidString,
              let address = order.address,
              let status = order.status else {
            throw FirebaseManagerError.invalidData
        }
        
        let orderData: [String: Any] = [
            "orderID": orderID,
            "productCost": order.productCost,
            "deliveryCharge": order.deliveryCharge,
            "promoCodeDiscount": order.promoCodeDiscount,
            "orderDate": order.orderDate ?? Date(),
            "paidByCard": order.paidByCard,
            "address": address,
            "latitude": order.latitude,
            "longitude": order.longitude,
            "orderComments": order.orderComments ?? "",
            "phone": order.phone ?? "",
            "status": status
        ]
        
        var itemsArray: [[String: Any]] = []
        if let orderItems = order.orderItems?.allObjects as? [OrderItemEntity] {
            for item in orderItems {
                guard let dishID = item.dishID,
                      let dishName = item.dishName else {
                    throw FirebaseManagerError.invalidData
                }
                
                let itemData: [String: Any] = [
                    "dishID": dishID,
                    "dishName": dishName,
                    "dishPrice": item.dishPrice,
                    "quantity": item.quantity
                ]
                itemsArray.append(itemData)
            }
        }
        
        var fullOrderData = orderData
        fullOrderData["items"] = itemsArray

        let collectionPath: String
        if auth.currentUser == nil {
            collectionPath = "guestOrders"
        } else {
            collectionPath = "orders/\(auth.currentUser!.uid)/userOrders"
        }
        
        do {
            try await firestore.collection(collectionPath).document(orderID).setData(fullOrderData)
        } catch {
            throw FirebaseManagerError.firestoreDataWasNotSaved(error)
        }
    }
    
    func fetchOrderHistoryFromFirestore() async throws -> [[String: Any]] {
        try checkConnection()
        
        guard let user = auth.currentUser else {
            throw FirebaseManagerError.authenticationFailed
        }
        
        let collectionPath = "orders/\(user.uid)/userOrders"
        do {
            let snapshot = try await firestore.collection(collectionPath).getDocuments()
            return snapshot.documents.map { $0.data() }
        } catch {
            throw FirebaseManagerError.firestoreDataWasNotReceived(error)
        }
    }
    
    // MARK: - Private methods
    
    private func getFirestoreData(_ collectionName: String) async throws -> [DocumentSnapshot] {
        try checkConnection()
        
      do {
        let snapshot = try await firestore.collection(collectionName).getDocuments()
        return snapshot.documents
      } catch {
        throw FirebaseManagerError.firestoreDataWasNotReceived(error)
      }
    }

    private func createOffer(from data: DocumentSnapshot) async throws -> Offer {
        try checkConnection()
        
        guard let offerData = try data.data(as: OfferDataModel?.self) else {
            throw FirebaseManagerError.parseDataFailed
        }

        let imageData = try await downloadImage(from: offerData.imageURL)

        return Offer(id: offerData.id,
                     name: offerData.name,
                     amount: offerData.offer,
                     condition: offerData.condition,
                     imageData: imageData)
    }

    private func createDish(from data: DocumentSnapshot) async throws -> Dish {
        try checkConnection()
        
        guard let dishData = try data.data(as: DishDataModel?.self) else {
            throw FirebaseManagerError.parseDataFailed
        }

        let imageData = try await downloadImage(from: dishData.imageURL)

        return Dish(id: dishData.id,
                    name: dishData.name,
                    description: dishData.description,
                    ingredients: dishData.ingredients,
                    tags: dishData.tags,
                    weight: dishData.weight,
                    calories: dishData.calories,
                    protein: dishData.protein,
                    carbs: dishData.carbs,
                    fats: dishData.fats,
                    isOffer: dishData.isOffer,
                    price: dishData.price,
                    recentPrice: dishData.recentPrice,
                    imageData: imageData)
    }
    
}
