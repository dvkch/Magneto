//
//  UIView+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension UIView {
    
    // hiding an item in a UIStackView that is already hidden breaks in UIKit and prevents us to ever make this item visible again
    var sy_isHidden: Bool {
        get { return isHidden }
        set {
            if newValue == isHidden { return }
            isHidden = newValue
        }
    }
}
