//
//  OfferEntity + Extension.swift
//  IngredientMix
//

import Foundation

extension OfferEntity {
    func update(with offer: Offer) {
        self.id = offer.id
        self.name = offer.name
        self.amount = offer.amount
        self.condition = offer.condition
        self.imageData = offer.imageData
    }
}
