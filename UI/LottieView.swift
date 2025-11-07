//
//  LottieView.swift
//  BoxTime
//
//  Created by Darian Hanci on 06.11.25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        // Lottie Animation View erstellen
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.play()
        
        // Auto Layout aktivieren
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
