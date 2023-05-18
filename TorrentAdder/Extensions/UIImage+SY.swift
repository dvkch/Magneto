//
//  UIImage+SY.swift
//  TorrentAdder
//
//  Created by syan on 17/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

extension UIImage {
    enum Traffic {
        case green, grey, orange, red
        
        fileprivate var color: UIColor {
            switch self {
            case .green:    return UIColor(red: 100, green: 203, blue:  87)
            case .grey:     return UIColor(red: 220, green: 220, blue: 220)
            case .orange:   return UIColor(red: 246, green: 195, blue:  80)
            case .red:      return UIColor(red: 237, green: 107, blue:  96)
            }
        }
    }
    static func traffic(_ traffic: Traffic) -> UIImage? {
        let size = UIFontMetrics.default.scaledValue(for: 12).rounded()
        let borderSize = (size / 8).rounded()

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size + 2 * borderSize, height: size + 2 * borderSize), false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let path = UIBezierPath(roundedRect: CGRect(x: borderSize, y: borderSize, width: size, height: size), cornerRadius: size / 2)
        path.lineWidth = size / 8
        UIColor.black.withAlphaComponent(0.3).setStroke()
        traffic.color.setFill()
        path.fill()
        path.stroke()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
