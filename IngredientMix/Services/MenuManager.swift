//
//  MenuManager.swift
//  IngredientMix
//

import Foundation

enum MenuManagerError: Error {
    case failedToCheckMenuRelevance
    case failedToGetLatestMenu
}

final class MenuManager {
    
    static let shared = MenuManager()
    
    private init() {}
    
    private let coreDataManager = CoreDataManager.shared
    private let firebaseManager = FirebaseManager.shared
    
    func isLatestMenuDownloaded() async throws -> Bool {
        do {
            let localVersion = try coreDataManager.getCurrentMenuVersionNumber()
            let latestVersion = try await firebaseManager.getLatestMenuVersionNumber()
            return localVersion == latestVersion
            
        } catch {
            if case FirebaseManagerError.noInternetConnection = error {
                throw error
            } else {
                throw MenuManagerError.failedToCheckMenuRelevance
            }
        }
    }
    
    func getLatestMenu() async throws -> Menu {
        do {
            async let fetchedMenu = firebaseManager.getMenu()
            async let latestVersion = firebaseManager.getLatestMenuVersionNumber()
            
            let menu = try await fetchedMenu
            let version = try await latestVersion
            
            try coreDataManager.saveMenu(menu, version: version)
            
            return menu
            
        } catch {
            if case FirebaseManagerError.noInternetConnection = error {
                throw error
            } else {
                throw MenuManagerError.failedToGetLatestMenu
            }
        }
    }
    
}
