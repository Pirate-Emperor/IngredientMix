//
//  PromoCodeManager.swift
//  IngredientMix
//

import Foundation

enum PromoCodeManagerError: Error {
    case activePromoCodeAlreadyExists
    case failedToSavePromoCode
    case failedToDeletePromoCode
    case promoCodeNotFound
}

final class PromoCodeManager {
    
    static let shared = PromoCodeManager()
    
    private init() {}
    
    private let coreDataManager = CoreDataManager.shared
    private let firebaseManager = FirebaseManager.shared
    
    func applyPromoCode(_ code: String) async throws -> PromoCodeEntity {
        
        guard !coreDataManager.isActivePromoCodeAlreadyExists() else {
            throw PromoCodeManagerError.activePromoCodeAlreadyExists
        }
        
        let promoCodeData = try await firebaseManager.applyPromoCode(code)
        
        let promoCodeEntity = coreDataManager.createPromoCode(from: promoCodeData)
        
        do {
            try coreDataManager.saveContext()
            return promoCodeEntity
        } catch {
            try coreDataManager.deleteEntityFromContext(promoCodeEntity)
            throw PromoCodeManagerError.failedToSavePromoCode
        }
    }
    
    func fetchPromoCode() throws -> PromoCodeEntity {
        do {
            return try coreDataManager.fetchPromoCode()
        } catch {
            throw PromoCodeManagerError.promoCodeNotFound
        }
    }
    
    func deletePromoCode() throws {
        do {
            try coreDataManager.deletePromoCode()
        } catch {
            throw PromoCodeManagerError.failedToDeletePromoCode
        }
    }
    
    func isActivePromoInStorage() -> Bool {
        coreDataManager.isActivePromoCodeAlreadyExists()
    }
    
}
