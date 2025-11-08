//
//  BoxTimeApp.swift
//  BoxTime
//
//  Created by Darian Hanci on 05.11.25.
//

import SwiftUI
import GoogleMobileAds

@main
struct BoxTimeApp: App {
    
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            InitialView()
        }
    }
}
