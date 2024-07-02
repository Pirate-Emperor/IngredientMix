//
//  DishDataModel.swift
//  IngredientMix
//

import Foundation

struct DishDataModel: Decodable {
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
    let imageURL: String
}
