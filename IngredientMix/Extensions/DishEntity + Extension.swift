//
//  DishEntity + Extension.swift
//  IngredientMix
//

import Foundation

extension DishEntity {
    func update(with dish: Dish) {
        self.id = dish.id
        self.name = dish.name
        self.dishDescription = dish.description
        self.ingredients = dish.ingredients
        self.tags = dish.tags as NSArray
        self.weight = Int64(dish.weight)
        self.calories = Int64(dish.calories)
        self.protein = Int64(dish.protein)
        self.carbs = Int64(dish.carbs)
        self.fats = Int64(dish.fats)
        self.isOffer = dish.isOffer
        self.price = dish.price
        self.recentPrice = dish.recentPrice ?? 0.0
        self.imageData = dish.imageData
        self.isFavorite = dish.isFavorite
    }
}
