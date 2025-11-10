//
//  PremiumManager.swift
//  BoxTime
//
//  Created by Darian Hanci on 08.11.25.
//

import Foundation
import Combine

class PremiumManager: ObservableObject {
    static let shared = PremiumManager()

    @Published var hasPremium: Bool = false
    @Published var premiumUntil: Date?

    private init() {
        if let date = UserDefaults.standard.object(forKey: "premiumUntil") as? Date {
            premiumUntil = date
            hasPremium = Date() < date
        } else {
            hasPremium = false
        }
    }

    func setPremium(until: Date) {
        premiumUntil = until
        hasPremium = Date() < until
        UserDefaults.standard.set(until, forKey: "premiumUntil")
    }

    func clearPremium() {
        premiumUntil = nil
        hasPremium = false
        UserDefaults.standard.removeObject(forKey: "premiumUntil")
    }
}
