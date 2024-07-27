//
//  OrderManager.swift
//  IngredientMix
//

import Foundation

final class OrderManager {
    
    static let shared = OrderManager()

    private init() {}

    private let coreDataManager = CoreDataManager.shared
    private let firebaseManager = FirebaseManager.shared
    
    func placeOrder(orderID: UUID = UUID(), productCost: Double, deliveryCharge: Double, promoCodeDiscount: Double, orderDate: Date = Date(), paidByCard: Bool, address: String, latitude: Double, longitude: Double, orderComments: String?, phone: String?, status: String = "Pending", orderItems: [OrderItemEntity]) async throws {
        
        let order = coreDataManager.createOrder(orderID: orderID, productCost: productCost, deliveryCharge: deliveryCharge, promoCodeDiscount: promoCodeDiscount, orderDate: orderDate, paidByCard: paidByCard, address: address, latitude: latitude, longitude: longitude, orderComments: orderComments, phone: phone, status: status, orderItems: orderItems)

        do {
            try await firebaseManager.saveOrderToFirestore(order)
            try coreDataManager.saveContext()
        } catch {
            try coreDataManager.deleteEntityFromContext(order)
            throw error
        }
    }

    func fetchOrderHistory() async throws {
        let firestoreOrders = try await firebaseManager.fetchOrderHistoryFromFirestore()
        try coreDataManager.deleteAllOrders()
        try coreDataManager.saveOrdersFromFirestore(firestoreOrders)
    }
}
