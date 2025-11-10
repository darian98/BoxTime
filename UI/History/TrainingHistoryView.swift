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
    @State private var showPremiumView: Bool = false
    
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
                
                Button {
                    showPremiumView.toggle()
                } label: {
                    Text("Die Vorteile von Premium anschauen!")
                }

                
            }
        }
        .padding()
        .fullScreenCover(isPresented: $showPremiumView) {
            PremiumView()
        }
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

