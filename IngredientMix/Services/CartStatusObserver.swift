//
//  CartStatusObserver.swift
//  IngredientMix
//

import CoreData

final class CartStatusObserver {
    
    static let shared = CartStatusObserver()
    
    private init() {}
    
    private var isCartEmpty = true
    
    var cartStatusDidChange: ((Bool) -> Void)?
    
    func observeCartStatus() throws {
        let isCurrentlyEmpty = try CoreDataManager.shared.cartIsEmpty()
        
        if isCurrentlyEmpty != isCartEmpty {
            isCartEmpty = isCurrentlyEmpty
            cartStatusDidChange?(isCartEmpty)
        }
    }
}
