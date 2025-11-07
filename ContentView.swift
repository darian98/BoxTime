//
//  ContentView.swift
//  BoxTime
//
//  Created by Darian Hanci on 07.11.25.
//
import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity) // sanfte Überblendung
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Nach 3 Sekunden Splash ausblenden
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
