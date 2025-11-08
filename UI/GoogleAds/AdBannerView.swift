//
//  AdBannerView.swift
//  BoxTime
//
//  Created by Darian Hanci on 08.11.25.
//
//
//  AdBannerView.swift
//  BoxTime
//
//  Created by Darian Hanci on 08.11.25.
//

import SwiftUI
import GoogleMobileAds

/// Unterstützte Bannergrößen
enum BannerType {
    case banner           // 320x50
    case largeBanner      // 320x100
    case mediumRectangle  // 300x250
    
    var adSize: AdSize {
        switch self {
        case .banner:
            return AdSizeBanner
        case .largeBanner:
            return AdSizeLargeBanner
        case .mediumRectangle:
            return AdSizeMediumRectangle
        }
    }
    
    var height: CGFloat {
        switch self {
        case .banner:
            return 50
        case .largeBanner:
            return 100
        case .mediumRectangle:
            return 250
        }
    }
}

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    let bannerType: BannerType
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: bannerType.adSize)
        bannerView.adUnitID = adUnitID
        
        // Hole das aktuelle Root View Controller-Fenster
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        
        bannerView.delegate = context.coordinator
        
        let request = Request()
        bannerView.load(request)
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // Optional: Handling bei Größenänderung etc.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        // Optional: Reagiere auf Ereignisse wie didReceiveAd oder didFailToReceiveAd
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("✅ Ad received successfully.")
        }
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
            print("❌ Failed to load ad: \(error.localizedDescription)")
        }
    }
}

