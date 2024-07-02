//
//  CartItem.swift
//  IngredientMix
//

import Foundation

struct CartItem: Equatable {
    let dish: Dish
    var quantity: Int
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.dish.id == rhs.dish.id && lhs.quantity == rhs.quantity
    }
}
