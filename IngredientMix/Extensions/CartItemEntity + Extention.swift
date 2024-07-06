//
//  CartItemEntity + Extention.swift
//  IngredientMix
//

import Foundation

extension CartItemEntity {
    func update(with cartItem: CartItem) {
        self.dishID = cartItem.dish.id
        self.quantity = Int64(cartItem.quantity)
    }
}
