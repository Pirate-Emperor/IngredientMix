//
//  ErrorLogger.swift
//  IngredientMix
//

import FirebaseCrashlytics

class ErrorLogger {

    static let shared = ErrorLogger()

    private init() {}

    func logError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        let nsError = error as NSError
        
        Crashlytics.crashlytics().record(error: nsError)
        
        if let info = additionalInfo {
            for (key, value) in info {
                Crashlytics.crashlytics().setCustomValue(value, forKey: key)
            }
        }
        
        Crashlytics.crashlytics().log("Error logged: \(error.localizedDescription)")
    }

    func logMessage(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    func logUserAction(_ action: String) {
        Crashlytics.crashlytics().setCustomValue(action, forKey: "User_Action")
    }

    func setUserID(_ userID: String) {
        Crashlytics.crashlytics().setUserID(userID)
    }
}

