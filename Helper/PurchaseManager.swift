//
//  PurchaseManager.swift
//  BoxTime
//
//  Created by Darian Hanci on 10.11.25.
//

import Foundation
import StoreKit
import Combine

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var threeMonthsProduct: Product?
    @Published var sixMonthsProduct: Product?
    @Published var oneYearProduct: Product?
    
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    
    // Keep a strong reference to the updates listener
    private var updatesListener: Task<Void, Never>?
    
    private init() {
        // Start listening for transaction updates immediately
        startListeningForTransactions()
        
        Task {
            await loadProducts()
            await restoreFromTransactions() // für Wiederherstellung bei App-Start
        }
    }
    
    deinit {
        updatesListener?.cancel()
    }
    
    func loadProducts() async {
        do {
            let ids: Set<String> = ["premium_3m","premium_6m", "premium_1y"]
            let products = try await Product.products(for: ids)
            
            for product in products {
                switch product.id {
                case "premium_3m":
                    self.threeMonthsProduct = product
                case "premium_6m":
                    self.sixMonthsProduct = product
                case "premium_1y":
                    self.oneYearProduct = product
                default:
                    break
                }
            }
        } catch {
            errorMessage = "Produkte konnten nicht geladen werden: \(error.localizedDescription)"
        }
    }
    
    func buyThreeMonths() async {
        await purchase(product: threeMonthsProduct)
    }
    
    func buySixMonths() async {
        await purchase(product: sixMonthsProduct)
    }
    
    func buyOneYear() async {
        await purchase(product: oneYearProduct)
    }
    
    private func purchase(product: Product?) async {
        guard let product = product else {
            errorMessage = "Produkt nicht gefunden."
            return
        }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if let transaction = try? checkVerified(verification) {
                    
                    await transaction.finish()
                    
                    await refreshEntitlements()
                    
                } else {
                    errorMessage = "Transaktion konnte nicht verifiziert werden."
                }
                
            case .userCancelled:
                break
                
            case .pending:
                // z.B. Ask to Buy – hier könntest du Info anzeigen
                break
                
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Kauf fehlgeschlagen: \(error.localizedDescription)"
        }
    }
    
    // Bei App-Start alle Transaktionen scannen, um Premium wiederherzustellen
    func restoreFromTransactions() async {
        do {
            try await AppStore.sync()
        } catch {
            print("AppStore.sync() failed: \(error.localizedDescription)")
        }
        
        await refreshEntitlements()
    }
    
    // Entitlements prüfen und Premium setzen (true/false)
    private func refreshEntitlements() async {
        var hasActive = false
        do {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    // prüfe nur unsere Abo-IDs
                    if ["premium_3m","premium_6m","premium_1y"].contains(transaction.productID) {
                        // aktiv wenn nicht widerrufen und (kein expDate oder expDate in Zukunft)
                        let notRevoked = (transaction.revocationDate == nil)
                        let notExpired = (transaction.expirationDate == nil) || (transaction.expirationDate! > Date())
                        if notRevoked && notExpired {
                            hasActive = true
                            // falls du weiterhin ein Datum speicherst: nimm expirationDate oder "fern" in der Zukunft
                            let until = transaction.expirationDate ?? .distantFuture
                            PremiumManager.shared.setPremium(until: until)
                            // nicht breaken – falls mehrere Produkte aktiv sind
                        }
                    }
                }
            }
        } catch {
            print("Fehler beim Entitlement-Check: \(error)")
        }
        
        if !hasActive {
            // kein aktives Abo → Premium aus
            // falls du clearPremium() hast, nutze das; sonst setze ein vergangenes Datum
            PremiumManager.shared.setPremium(until: Date.distantPast)
        }
    }
    
    // Start a continuous listener for transaction updates
    private func startListeningForTransactions() {
        updatesListener = Task { [weak self] in
            guard let self else { return }
            for await update in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(update)
                    await self.applyEntitlementAndFinishIfNeeded(transaction: transaction)
                } catch {
                    // Ignore unverified updates
                    continue
                }
            }
        }
    }
    
    // Für Auto-Renewables: kein Monatsrechnen, sondern Entitlement prüfen
    private func applyEntitlementAndFinishIfNeeded(transaction: Transaction) async {
        guard ["premium_3m","premium_6m","premium_1y"].contains(transaction.productID) else {
            return
        }
        
        let notRevoked = (transaction.revocationDate == nil)
        let notExpired = (transaction.expirationDate == nil) || (transaction.expirationDate! > Date())
        if notRevoked && notExpired {
            let until = transaction.expirationDate ?? .distantFuture
            PremiumManager.shared.setPremium(until: until)
        }
        
        await transaction.finish()
    }
    
    private enum VerificationError: Error {
        case failed
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw VerificationError.failed
        case .verified(let safe):
            return safe
        }
    }
}
