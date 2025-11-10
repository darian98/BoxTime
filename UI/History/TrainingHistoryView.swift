//
//  TrainingHistoryView.swift
//  BoxTime
//
//  Created by Darian Hanci on 08.11.25.
//
import SwiftUI

struct TrainingHistoryView: View {
    var body: some View {
        VStack {
            Text("Historie nur für Premium-User verfügbar!")
            
            Button {
                print("Premium kaufen tapped!")
            } label: {
                Text("Premium kaufen")
            }
            .padding(24)

        }
    }
}
