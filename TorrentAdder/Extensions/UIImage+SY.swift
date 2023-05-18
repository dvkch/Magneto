//
//  UIImage+SY.swift
//  TorrentAdder
//
//  Created by syan on 17/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

extension UIImage {
    enum Icon: String {
        case help       = "questionmark"
        case openMagnet = "arrowshape.turn.up.right"
        case cloud      = "icloud"
        case edit       = "pencil"                  // 17x15
        case delete     = "trash"                   // 19x21
        case share      = "square.and.arrow.up"     // 19x21
        case openWeb    = "safari"
        case empty      = "tray"

        case bookmark   = "bookmark"
        case network    = "network"                 // 20x19
        case number     = "number"
        case app        = "macwindow"
        case user       = "person"
        case secret     = "eyes"

        case checkmark  = "checkmark"               // 18x16
        case close      = "xmark"                   // 17x15
        case left       = "chevron.left"            // 13x17
        case right      = "chevron.right"           // 13x17

        var availableVariantsCount: Int {
            switch self {
            case .right:    return 12
            case .close:    return  4
            default:        return  1
            }
        }
        
        func assetName(variant: Int?) -> String {
            guard availableVariantsCount > 1 else { return rawValue }
            let boundedVariant: Int
            if let variant {
                boundedVariant = variant % availableVariantsCount
            }
            else {
                boundedVariant = Int.random(in: 0..<availableVariantsCount)
            }
            return "\(rawValue).\(boundedVariant)"
        }
    }

    static func icon(_ icon: Icon, variant: Int? = 0, useSystem: Bool = false) -> UIImage? {
        if useSystem {
            return UIImage(systemName: icon.rawValue)
        }

        return UIImage(named: icon.assetName(variant: variant)) ?? UIImage(systemName: icon.rawValue)
    }
}

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
