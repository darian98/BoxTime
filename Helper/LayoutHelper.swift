//
//  LayoutHelper.swift
//  BoxTime
//
//  Created by Darian Hanci on 10.11.25.
//

import UIKit

import UIKit

struct LayoutHelper {
    static func adBottomPadding() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch screenHeight {
        case ..<670:
            // z.B. iPhone SE, 8, 7, 6s (sehr kleine / alte Größen)
            return 24
            
        case 670..<740:
            // z.B. iPhone 11 Pro, 12/13 mini etc. (klein aber moderner Formfaktor)
            return 22
            
        case 740..<820:
            // z.B. iPhone 11, XR
            return 20
            
        case 820..<880:
            // z.B. iPhone 14 / 15 / 14 Pro etc. (dein "Ideal")
            return 18
            
        case 880..<930:
            // z.B. 14 Plus, 15 Plus, ältere Max-Devices
            return 12
            
        default:
            // neuere / sehr große Max-Devices (z.B. 16 Pro Max)
            return 6
        }
    }
}

