//
//  Offer.swift
//  IngredientMix
//

import Foundation

struct Offer: Hashable {
    let id: String
    let name: String
    let amount: String
    let condition: String
    let imageData: Data?
}

extension Offer {
    init(from entity: OfferEntity) {
        self.id = entity.id!
        self.name = entity.name!
        self.amount = entity.amount!
        self.condition = entity.condition!
        self.imageData = entity.imageData
    }
}
