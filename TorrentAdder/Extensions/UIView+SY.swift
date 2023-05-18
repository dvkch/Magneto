//
//  UIView+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension UIView {
    func addGlow(color: UIColor?, size: CGFloat) {
        layer.shadowColor = (color ?? tintColor)?.cgColor
        layer.shadowRadius = size
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.masksToBounds = false
    }
    
    #if targetEnvironment(macCatalyst)
    var focusRingType: UInt {
        get { (perform(Selector(("_focusRingType")))?.takeUnretainedValue() as? NSNumber)?.uintValue ?? 0 }
        set {
            guard [0, 1, 2].contains(newValue) else { return print("Should be using a real value") }
            perform(Selector(("_setFocusRingType:")), with: newValue)
        }
    }
    #else
    var focusRingType: UInt {
        get { return 0 }
        set { }
    }
    #endif
}
