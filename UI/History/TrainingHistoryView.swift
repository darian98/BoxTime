//
//  TrainingHistoryView.swift
//  BoxTime
//
//  Created by Darian Hanci on 08.11.25.
//
import SwiftUI

import SwiftUI
import StoreKit

struct TrainingHistoryView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var premiumManager = PremiumManager.shared

    var body: some View {
        VStack(spacing: 20) {
            if premiumManager.hasPremium {
                Text("Deine Trainingshistorie 🎉")
                    .font(.title2)
                if let until = premiumManager.premiumUntil {
                    Text("Premium gültig bis: \(until.formatted(date: .long, time: .shortened))")
                        .font(.subheadline)
                }
            } else {
                Text("Historie nur für Premium-User verfügbar!")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                if let error = purchaseManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if let three = purchaseManager.threeMonthsProduct {
                    Button {
                        Task { await purchaseManager.buyThreeMonths() }
                    } label: {
                        buttonLabel(title: "3 Monate Premium", price: three.displayPrice)
                    }
                }
                
                if let six = purchaseManager.sixMonthsProduct {
                    Button {
                        Task { await purchaseManager.buySixMonths() }
                    } label: {
                        buttonLabel(title: "6 Monate Premium", price: six.displayPrice)
                    }
                }

                if let year = purchaseManager.oneYearProduct {
                    Button {
                        Task { await purchaseManager.buyOneYear() }
                    } label: {
                        buttonLabel(title: "1 Jahr Premium", price: year.displayPrice)
                    }
                }
            }
        }
        .padding()
    }

    private func buttonLabel(title: String, price: String) -> some View {
        HStack {
            Text(title)
                .bold()
            Spacer()
            Text(price)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

