//
//  CoreDataManager.swift
//  IngredientMix
//

import Foundation
import CoreData
import FirebaseAuth

enum CoreDataManagerError: Error {
    case fetchError(Error)
    case saveError(Error)
    case deleteError(Error)
    case itemNotFound
    case itemAlreadyExists
}

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Base")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw CoreDataManagerError.saveError(error)
            }
        }
    }
    
    func deleteEntityFromContext<EntityType: NSManagedObject>(_ entity: EntityType) throws {
        
        guard context.registeredObject(for: entity.objectID) != nil else {
            throw CoreDataManagerError.itemNotFound
        }
        
        context.delete(entity)
        
        do {
            try saveContext()
        } catch {
            context.undo()
            throw CoreDataManagerError.deleteError(error)
        }
    }

    // MARK: - Menu methods
    
    func fetchMenu() throws -> Menu? {
        let fetchRequestDishes: NSFetchRequest<DishEntity> = DishEntity.fetchRequest()
        let fetchRequestOffers: NSFetchRequest<OfferEntity> = OfferEntity.fetchRequest()
        let fetchRequestTags: NSFetchRequest<TagsContainerEntity> = TagsContainerEntity.fetchRequest()
        
        do {
            let dishEntities = try context.fetch(fetchRequestDishes)
            let offerEntities = try context.fetch(fetchRequestOffers)
            let tagsContainerEntities = try context.fetch(fetchRequestTags)
            
            let dishes = dishEntities.map { Dish(from: $0) }
            let offers = offerEntities.map { Offer(from: $0) }
            let tags = (tagsContainerEntities.first?.tags as? [String]) ?? []
            
            if dishes.isEmpty && offers.isEmpty && tags.isEmpty {
                return nil
            }
            
            return Menu(offers: offers, dishes: dishes, tags: tags)
            
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }

    
    func saveMenu(_ menu: Menu, version: String) throws {
        // Fetch existing favorite dish IDs
        let favoriteDishes = try fetchFavorites()
        let favoriteDishIDs = Set(favoriteDishes.map { $0.id })
        
        // Clear existing data
        do {
            try deleteMenu()
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
        
        // Save new menu data
        for dish in menu.dishes {
            let dishEntity = DishEntity(context: context)
            dishEntity.update(with: dish)
            if favoriteDishIDs.contains(dish.id) {
                dishEntity.isFavorite = true
            }
        }
        
        for offer in menu.offersContainer.offers {
            let offerEntity = OfferEntity(context: context)
            offerEntity.update(with: offer)
        }
        
        let tagsContainerEntity = TagsContainerEntity(context: context)
        tagsContainerEntity.tags = menu.tagsContainer.tags as NSObject
        
        // Save menu version
        let fetchRequest: NSFetchRequest<MenuVersion> = MenuVersion.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            let versionNumber: MenuVersion
            if let existingVersionNumbers = results.first {
                versionNumber = existingVersionNumbers
            } else {
                versionNumber = MenuVersion(context: context)
            }
            
            versionNumber.version = version
        } catch {
            throw CoreDataManagerError.saveError(error)
        }
        
        try saveContext()
    }

    
    func deleteMenu() throws {
        let fetchRequestDishes: NSFetchRequest<NSFetchRequestResult> = DishEntity.fetchRequest()
        let fetchRequestOffers: NSFetchRequest<NSFetchRequestResult> = OfferEntity.fetchRequest()
        let fetchRequestTags: NSFetchRequest<NSFetchRequestResult> = TagsContainerEntity.fetchRequest()
        
        let batchDeleteRequestDishes = NSBatchDeleteRequest(fetchRequest: fetchRequestDishes)
        let batchDeleteRequestOffers = NSBatchDeleteRequest(fetchRequest: fetchRequestOffers)
        let batchDeleteRequestTags = NSBatchDeleteRequest(fetchRequest: fetchRequestTags)
        
        do {
            try context.execute(batchDeleteRequestDishes)
            try context.execute(batchDeleteRequestOffers)
            try context.execute(batchDeleteRequestTags)
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
    }
    
    func isMenuDifferentFrom(_ newMenu: Menu) throws -> Bool {
        guard let existingMenu = try fetchMenu() else { return true }
        
        let existingDishIDs = Set(existingMenu.dishes.map { $0.id })
        let newDishIDs = Set(newMenu.dishes.map { $0.id })
        
        let existingOfferIDs = Set(existingMenu.offersContainer.offers.map { $0.id })
        let newOfferIDs = Set(newMenu.offersContainer.offers.map { $0.id })
        
        return existingDishIDs != newDishIDs || existingOfferIDs != newOfferIDs
    }
    
    func getCurrentMenuVersionNumber() throws -> String? {
        let fetchRequest: NSFetchRequest<MenuVersion> = MenuVersion.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.version
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    func deleteCurrentMenuVersion() { // method for testing
        let fetchRequest: NSFetchRequest<MenuVersion> = MenuVersion.fetchRequest()
        
        do {
            if let menuVersion = try context.fetch(fetchRequest).first {
                context.delete(menuVersion)
                try saveContext()
            } else {
                print("Menu version not found.")
            }
        } catch {
            print("Error fetching menu version: \(error)")
        }
    }
    
    // MARK: - Favorite methods
    
    func fetchFavorites() throws -> [Dish] {
        let fetchRequest: NSFetchRequest<DishEntity> = DishEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isFavorite == true")
        
        do {
            let dishEntities = try context.fetch(fetchRequest)
            return dishEntities.map { Dish(from: $0) }
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    func setAsFavorite(by dishID: String) throws {
        let fetchRequest: NSFetchRequest<DishEntity> = DishEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", dishID)
        
        do {
            let dishes = try context.fetch(fetchRequest)
            if let dish = dishes.first {
                dish.isFavorite = true
            } else {
                throw CoreDataManagerError.itemNotFound
            }
        } catch {
            throw CoreDataManagerError.saveError(error)
        }
        
        try saveContext()
    }
    
    func deleteFromFavorite(by dishID: String) throws {
        let fetchRequest: NSFetchRequest<DishEntity> = DishEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", dishID)
        
        do {
            let dishes = try context.fetch(fetchRequest)
            if let dish = dishes.first {
                dish.isFavorite = false
            } else {
                throw CoreDataManagerError.itemNotFound
            }
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
        
        try saveContext()
    }
    
    // MARK: - Cart methods
    
    func saveCartItem(dish: Dish, quantity: Int) throws {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dishID == %@", dish.id)
        
        do {
            let cartItems = try context.fetch(fetchRequest)
            
            if let existingCartItem = cartItems.first {
                existingCartItem.quantity += Int64(quantity)
            } else {
                let cartItemEntity = CartItemEntity(context: context)
                cartItemEntity.dishID = dish.id
                cartItemEntity.quantity = Int64(quantity)
            }
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
        
        try saveContext()
        try CartStatusObserver.shared.observeCartStatus()
    }
    
    func deleteCartItem(by dishID: String) throws {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dishID == %@", dishID)
        
        do {
            let cartItems = try context.fetch(fetchRequest)
            
            if let cartItem = cartItems.first {
                context.delete(cartItem)
            } else {
                print("Cart item with dishID \(dishID) not found.")
                throw CoreDataManagerError.itemNotFound
            }
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
        
        try saveContext()
        try CartStatusObserver.shared.observeCartStatus()
    }
    
    func fetchCart() throws -> [CartItem] {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        
        do {
            let cartItemEntities = try context.fetch(fetchRequest)
            var cartItems: [CartItem] = []
            
            for entity in cartItemEntities {
                do {
                    let dish = try fetchDish(by: entity.dishID!)
                    let cartItem = CartItem(dish: dish, quantity: Int(entity.quantity))
                    cartItems.append(cartItem)
                } catch {
                    continue
                }
            }
            
            return cartItems
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    func saveCart(_ cartItems: [CartItem]) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CartItemEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
            for item in cartItems {
                let cartItemEntity = CartItemEntity(context: context)
                cartItemEntity.update(with: item)
            }
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
        
        try saveContext()
    }
    
    func clearCart() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CartItemEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
        
        try saveContext()
        try CartStatusObserver.shared.observeCartStatus()
    }
    
    func cartIsEmpty() throws -> Bool {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        
        do {
            let itemCount = try context.count(for: fetchRequest)
            return itemCount == 0
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    // MARK: - Dish methods
    
    func findSimilarDishes(to dish: Dish, limit: Int = 3) throws -> [Dish] {
        let fetchRequest: NSFetchRequest<DishEntity> = DishEntity.fetchRequest()
        
        do {
            let dishEntities = try context.fetch(fetchRequest)
            let dishes = dishEntities.map { Dish(from: $0) }
            let filteredDishes = dishes.filter { $0.id != dish.id }
            let similarDishes = filteredDishes.sorted { (dish1, dish2) -> Bool in
                return tagSimilarity(between: dish, and: dish1) > tagSimilarity(between: dish, and: dish2)
            }
            return Array(similarDishes.prefix(limit))
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    private func tagSimilarity(between dish1: Dish, and dish2: Dish) -> Int {
        let commonTags = Set(dish1.tags).intersection(Set(dish2.tags))
        return commonTags.count
    }
    
    func fetchDish(by id: String) throws -> Dish {
        let fetchRequest: NSFetchRequest<DishEntity> = DishEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let dishes = try context.fetch(fetchRequest)
            if let dishEntity = dishes.first {
                return Dish(from: dishEntity)
            } else {
                throw CoreDataManagerError.itemNotFound
            }
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    // MARK: - Payment card methods
    
    func fetchAllCards() throws -> [CardEntity] {
        let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    func saveCard(cardName: String, cardNumber: String, cardExpirationDate: String, cardCVC: String, cardholderName: String, isPreferred: Bool) throws {
        guard !cardNameExists(cardName) else {
            throw CoreDataManagerError.itemAlreadyExists
        }
        
        do {
            let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
            let cards = try context.fetch(fetchRequest)
            
            let shouldBePreferred = cards.isEmpty || isPreferred
            
            if shouldBePreferred {
                for card in cards {
                    card.isPreferred = false
                }
            }
            
            let cardEntity = CardEntity(context: context)
            cardEntity.cardNumber = cardNumber
            cardEntity.cardName = cardName
            cardEntity.cardholderName = cardholderName
            cardEntity.cardExpirationDate = cardExpirationDate
            cardEntity.cardCVC = cardCVC
            cardEntity.isPreferred = shouldBePreferred
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
        
        try saveContext()
    }

    func deleteCard(by cardName: String) throws {
        let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cardName == %@", cardName)
        
        do {
            let cards = try context.fetch(fetchRequest)
            if let card = cards.first {
                context.delete(card)
            } else {
                throw CoreDataManagerError.itemNotFound
            }
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
        
        try saveContext()
    }
    
    func setPreferredCard(by cardName: String) throws {
        let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        
        do {
            let cards = try context.fetch(fetchRequest)
            for card in cards {
                card.isPreferred = (card.cardName == cardName)
            }
        } catch {
            throw CoreDataManagerError.saveError(error)
        }
        
        try saveContext()
    }
    
    func getPreferredCardName() -> String? {
        let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isPreferred == true")
        fetchRequest.fetchLimit = 1
        
        do {
            if let preferredCard = try context.fetch(fetchRequest).first {
                return preferredCard.cardName
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func cardNameExists(_ cardName: String) -> Bool {
        let fetchRequest: NSFetchRequest<CardEntity> = CardEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cardName == %@", cardName)
        
        do {
            let cards = try context.fetch(fetchRequest)
            return !cards.isEmpty
        } catch {
            print("Failed to fetch card by cardName: \(error)")
            return false
        }
    }
    
    // MARK: - Delivery address methods
    
    func fetchAllAddresses() throws -> [AddressEntity] {
        let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    func saveAddress(placeName: String, address: String, latitude: Double, longitude: Double, isDefaultAddress: Bool) throws {
        guard !placeNameExists(placeName) else {
            throw CoreDataManagerError.itemAlreadyExists
        }
        
        do {
            let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
            let addresses = try context.fetch(fetchRequest)
            
            let shouldBeDefault = addresses.isEmpty || isDefaultAddress
            
            if shouldBeDefault {
                for address in addresses {
                    address.isDefaultAddress = false
                }
            }
            
            let addressEntity = AddressEntity(context: context)
            addressEntity.placeName = placeName
            addressEntity.address = address
            addressEntity.latitude = latitude
            addressEntity.longitude = longitude
            addressEntity.isDefaultAddress = shouldBeDefault
            
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
        
        try saveContext()
    }
    
    func updateAddress(oldPlaceName: String, newPlaceName: String, address: String, latitude: Double, longitude: Double) throws {
        if oldPlaceName != newPlaceName && placeNameExists(newPlaceName) {
            throw CoreDataManagerError.itemAlreadyExists
        }
        
        let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "placeName == %@", oldPlaceName)
        
        do {
            let addresses = try context.fetch(fetchRequest)
            
            if let addressEntity = addresses.first {
                addressEntity.placeName = newPlaceName
                addressEntity.address = address
                addressEntity.latitude = latitude
                addressEntity.longitude = longitude
            } else {
                throw CoreDataManagerError.itemNotFound
            }
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
        
        try saveContext()
    }

    
    func deleteAddress(by placeName: String) throws {
        let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "placeName == %@", placeName)
        
        do {
            let addresses = try context.fetch(fetchRequest)
            for address in addresses {
                context.delete(address)
            }
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
        
        try saveContext()
    }
    
    func setAddressAsDefault(by placeName: String) throws {
        let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        
        do {
            let addresses = try context.fetch(fetchRequest)
            for address in addresses {
                address.isDefaultAddress = (address.placeName == placeName)
            }
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
        
        try saveContext()
    }

    func getDefaultAddress() -> AddressEntity? {
        let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDefaultAddress == true")
        fetchRequest.fetchLimit = 1
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            return nil
        }
    }
    
    func placeNameExists(_ placeName: String) -> Bool {
        let fetchRequest: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "placeName == %@", placeName)
        
        do {
            let addresses = try context.fetch(fetchRequest)
            return !addresses.isEmpty
        } catch {
            print("Failed to fetch address by placeName: \(error)")
            return false
        }
    }
    
    // MARK: - User data methods
    
    func saveUser(_ user: User) throws {
        let userEntity = UserEntity(context: context)
        userEntity.id = user.uid
        userEntity.email = user.email
        userEntity.displayName = user.displayName
        userEntity.avatarURL = user.photoURL?.absoluteString
        
        try saveContext()
    }

    func fetchUser() throws -> UserEntity? {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }

    
    func setDisplayName(_ name: String) throws {
        guard let user = try fetchUser() else {
            throw CoreDataManagerError.itemNotFound
        }
        
        user.displayName = name
        try saveContext()
    }

    
    func updateEmail(_ newEmail: String) throws {
        guard let user = try fetchUser() else {
            throw CoreDataManagerError.itemNotFound
        }
        
        user.email = newEmail
        try saveContext()
    }

    
    func savePhoneNumber(_ phoneNumber: String) throws {
        guard let user = try fetchUser() else {
            throw CoreDataManagerError.itemNotFound
        }
        
        user.phoneNumber = phoneNumber
        try saveContext()
    }

    
    func updateUserAvatar(avatarData: Data?, avatarURL: String?) throws {
        guard let user = try fetchUser() else {
            throw CoreDataManagerError.itemNotFound
        }
        
        user.avatar = avatarData
        user.avatarURL = avatarURL
        try saveContext()
    }

    
    func updateUserAvatar(with avatarData: Data) throws {
        guard let user = try fetchUser() else {
            throw CoreDataManagerError.itemNotFound
        }
        
        user.avatar = avatarData
        try saveContext()
    }

    func deleteUser() throws {
        guard let user = try fetchUser() else {
            throw CoreDataManagerError.itemNotFound
        }
        
        context.delete(user)
        try saveContext()
    }

    
    // MARK: - Orders methods
    
    func createOrder(orderID: UUID = UUID(), productCost: Double, deliveryCharge: Double, promoCodeDiscount: Double, orderDate: Date = Date(), paidByCard: Bool, address: String, latitude: Double, longitude: Double, orderComments: String?, phone: String?, status: String = "Pending", orderItems: [OrderItemEntity]) -> OrderEntity {
        let order = OrderEntity(context: context)
        order.orderID = orderID
        order.productCost = productCost
        order.deliveryCharge = deliveryCharge
        order.promoCodeDiscount = promoCodeDiscount
        order.orderComments = orderComments
        order.orderDate = orderDate
        order.paidByCard = paidByCard
        order.address = address
        order.latitude = latitude
        order.longitude = longitude
        order.phone = phone
        order.status = status
        
        for item in orderItems {
            order.addToOrderItems(item)
        }
        
        return order
    }
    
    func saveOrdersFromFirestore(_ ordersData: [[String: Any]]) throws {
        let context = persistentContainer.viewContext

        for orderData in ordersData {
            let order = OrderEntity(context: context)

            order.orderID = orderData["orderID"] as? UUID ?? UUID()
            order.productCost = orderData["productCost"] as? Double ?? 0.0
            order.deliveryCharge = orderData["deliveryCharge"] as? Double ?? 0.0
            order.promoCodeDiscount = orderData["promoCodeDiscount"] as? Double ?? 0.0
            order.orderDate = orderData["orderDate"] as? Date ?? Date()
            order.paidByCard = orderData["paidByCard"] as? Bool ?? false
            order.address = orderData["address"] as? String ?? ""
            order.latitude = orderData["latitude"] as? Double ?? 0.0
            order.longitude = orderData["longitude"] as? Double ?? 0.0
            order.orderComments = orderData["orderComments"] as? String
            order.phone = orderData["phone"] as? String
            order.status = orderData["status"] as? String ?? "Pending"

            if let orderItemsData = orderData["orderItems"] as? [[String: Any]] {
                for itemData in orderItemsData {
                    let orderItem = OrderItemEntity(context: context)
                    orderItem.dishName = itemData["name"] as? String
                    orderItem.quantity = itemData["quantity"] as? Int64 ?? 0
                    orderItem.dishPrice = itemData["price"] as? Double ?? 0.0
                    order.addToOrderItems(orderItem)
                }
            }
        }

        try saveContext()
    }
    
    func fetchOrders() throws -> [OrderEntity] {
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "orderDate", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try context.fetch(request)
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    func deleteAllOrders() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = OrderEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
        
        try saveContext()
    }
    
    // MARK: - Promo code methods
    
    func isActivePromoCodeAlreadyExists() -> Bool {
        let fetchRequest: NSFetchRequest<PromoCodeEntity> = PromoCodeEntity.fetchRequest()
        
        do {
            let promoCode = try context.fetch(fetchRequest)
            return !promoCode.isEmpty
        } catch {
            print("Failed to fetch promo code: \(error)")
            return false
        }
    }
    
    func createPromoCode(from data: (discountPercentage: Int, freeDelivery: Bool, expirationDate: Date)) -> PromoCodeEntity {
        let promoCode = PromoCodeEntity(context: context)
        promoCode.discountPercentage = Int64(data.discountPercentage)
        promoCode.freeDelivery = data.freeDelivery
        promoCode.expirationDate = data.expirationDate
        
        return promoCode
    }
    
    func fetchPromoCode() throws -> PromoCodeEntity {
        let request: NSFetchRequest<PromoCodeEntity> = PromoCodeEntity.fetchRequest()
        
        do {
            if let promoCode = try context.fetch(request).first {
                return promoCode
            } else {
                throw CoreDataManagerError.itemNotFound
            }
        } catch {
            throw CoreDataManagerError.fetchError(error)
        }
    }
    
    func deletePromoCode() throws {
        let request: NSFetchRequest<PromoCodeEntity> = PromoCodeEntity.fetchRequest()
        
        do {
            if let promoCode = try context.fetch(request).first {
                context.delete(promoCode)
                try saveContext()
            } else {
                throw CoreDataManagerError.itemNotFound
            }
        } catch {
            throw CoreDataManagerError.deleteError(error)
        }
    }
    
}
