//
//  OfferDataModel.swift
//  IngredientMix
//

import Foundation

struct OfferDataModel: Decodable {
    let id: String
    let name: String
    let offer: String
    let condition: String
    let imageURL: String
}
