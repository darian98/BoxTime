//
//  PremiumView.swift
//  BoxTime
//
//  Created by Darian Hanci on 10.11.25.
//
import SwiftUI
import StoreKit

struct PremiumView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let purchaseManager = PurchaseManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BoxTime Premium")
                            .font(.largeTitle.bold())
                        
                        Text("Hol dir alle Funktionen für dein bestes Trainingserlebnis.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Fehlernachricht
                    if let error = purchaseManager.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(12)
                    }
                    
                    // Premium-Vorteile
                    VStack(alignment: .leading, spacing: 16) {
                        premiumBenefitRow(
                            systemImage: "clock.badge.checkmark",
                            title: "Individuelle TrainingSessions",
                            description: "Erstelle eigene Workouts mit deinen Lieblingsübungen und lasse sie automatisch mit dem BoxTime-Timer ablaufen."
                        )
                        
                        premiumBenefitRow(
                            systemImage: "nosign",
                            title: "Keine Werbung",
                            description: "Konzentriere dich voll auf dein Training – komplett ohne Banner oder Unterbrechungen."
                        )
                        
                        premiumBenefitRow(
                            systemImage: "chart.line.uptrend.xyaxis",
                            title: "Trainingshistorie",
                            description: "Sieh, wie du dich entwickelst: Alle absolvierten Übungen und Sessions werden für dich gespeichert."
                        )
                    }
                    
                    // Kaufoptionen
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Wähle dein Premium-Paket")
                            .font(.headline)
                        
                        if let three = purchaseManager.threeMonthsProduct {
                            Button {
                                Task { await purchaseManager.buyThreeMonths() }
                            } label: {
                                purchaseButtonLabel(
                                    title: "3 Monate Premium",
                                    subtitle: "Perfekt zum Ausprobieren",
                                    price: three.displayPrice
                                )
                            }
                        }
                        
                        if let six = purchaseManager.sixMonthsProduct {
                            Button {
                                Task { await purchaseManager.buySixMonths() }
                            } label: {
                                purchaseButtonLabel(
                                    title: "6 Monate Premium",
                                    subtitle: "Beliebt bei regelmäßigen Trainierenden",
                                    price: six.displayPrice
                                )
                            }
                        }

                        if let year = purchaseManager.oneYearProduct {
                            Button {
                                Task { await purchaseManager.buyOneYear() }
                            } label: {
                                purchaseButtonLabel(
                                    title: "1 Jahr Premium",
                                    subtitle: "Maximaler Fokus – das beste Preis-Leistungs-Verhältnis",
                                    price: year.displayPrice
                                )
                            }
                        }
                    }
                    
                    Spacer(minLength: 16)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }
        }
    }
    
    // MARK: - UI-Bausteine
    
    private func premiumBenefitRow(systemImage: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 32, height: 32)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func purchaseButtonLabel(title: String, subtitle: String, price: String) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(price)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.blue.opacity(0.08))
        )
    }
}
