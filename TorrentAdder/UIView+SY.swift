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
}
