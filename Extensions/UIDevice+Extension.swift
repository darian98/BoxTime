//
//  UIDevice+Extension.swift
//  BoxTime
//
//  Created by Darian Hanci on 10.11.25.
//
import UIKit

extension UIDevice {
    var isHomeButtonDevice: Bool {
        getSafeAreaInsets().bottom == 0
    }
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func getSafeAreaInsets() -> UIEdgeInsets {
        guard let window = UIApplication.shared.keyWindow else {
            return .zero
        }
        return window.safeAreaInsets
    }
}
