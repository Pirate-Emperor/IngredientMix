//
//  Dish.swift
//  IngredientMix
//

import Foundation

struct Dish: Hashable {
    let id: String
    let name: String
    let description: String
    let ingredients: String
    let tags: [String]
    let weight: Int
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    let isOffer: Bool
    let price: Double
    let recentPrice: Double?
    let imageData: Data?
    var isFavorite: Bool = false
}

extension Dish {
    init(from entity: DishEntity) {
        self.id = entity.id!
        self.name = entity.name!
        self.description = entity.dishDescription!
        self.ingredients = entity.ingredients!
        self.tags = entity.tags as? [String] ?? []
        self.weight = Int(entity.weight)
        self.calories = Int(entity.calories)
        self.protein = Int(entity.protein)
        self.carbs = Int(entity.carbs)
        self.fats = Int(entity.fats)
        self.isOffer = entity.isOffer
        self.price = entity.price
        self.recentPrice = entity.recentPrice
        self.imageData = entity.imageData
        self.isFavorite = entity.isFavorite
    }
}
