//
//  Menu.swift
//  IngredientMix
//

import Foundation

struct Menu: Hashable {
    
    var offersContainer: OffersContainer
    var tagsContainer = TagsContainer(tags: [])
    var dishes: [Dish]
    
    init(offers: [Offer] = [], dishes: [Dish] = [], tags: [String] = []) {
        self.offersContainer = OffersContainer(offers: offers)
        self.dishes = dishes
        
        if tags.isEmpty {
            dishes.forEach { dish in
                for tag in dish.tags {
                    if !tagsContainer.tags.contains(tag) {
                        tagsContainer.tags.append(tag)
                    }
                }
            }
        } else {
            tagsContainer.tags = tags
        }
    }
}
