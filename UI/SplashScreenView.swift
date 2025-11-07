//
//  SplashScreenView.swift
//  BoxTime
//
//  Created by Darian Hanci on 06.11.25.
//
import SwiftUI
import Lottie

struct SplashScreenView: View {
    var body: some View {
        VStack {
            LottieView(animationName: "boxingBonePuppy", loopMode: .loop)
                .frame(width: 200, height: 200)
        }
    }
}
