//
//  UIColor+SY.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
    }
    
    static var tint: UIColor {
        let light = UIColor(red: 64 / 255, green: 146 / 255, blue: 247 / 255, alpha: 1)
        let dark  = UIColor(red:  0 / 255, green: 106 / 255, blue: 230 / 255, alpha: 1)
        return UIColor(light: light, dark: dark)
    }
    
    static var darkTint: UIColor {
        return UIColor(red: 22, green: 59, blue: 190).withAlphaComponent(0.5)
    }
    
    static var background: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGroupedBackground
        } else {
            return .groupTableViewBackground
        }
    }

    static var backgroundAlt: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemGroupedBackground
        } else {
            return .white
        }
    }
    
    static var cellBackground: UIColor {
        if UIDevice.isCatalyst {
            return .background
        }
        if #available(iOS 13.0, *) {
            return .secondarySystemGroupedBackground
        } else {
            return .white
        }
    }

    static var cellBackgroundAlt: UIColor {
        if UIDevice.isCatalyst {
            return .background
        }
        return cellBackground.withAlphaComponent(0.90)
    }

    static var splitSeparator: UIColor {
        if UIDevice.isCatalyst {
            return UIColor.black
        } else if #available(iOS 13.0, *) {
            return UIColor.opaqueSeparator
        } else {
            return UIColor.darkGray
        }
    }

    static var normalText: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.darkText
        }
    }
    
    static var normalTextOnTint: UIColor {
        return .white
    }

    static var altText: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor.darkGray
        }
    }

    static var altTextOnTint: UIColor {
        return UIColor.lightGray
    }

    static var disabledText: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.placeholderText
        } else {
            return UIColor.lightGray
        }
    }

    static var seeder: UIColor {
        return UIColor(red: 0.39, green: 0.79, blue: 0.34, alpha: 1)
    }

    static var leechers: UIColor {
        return .systemRed
    }
    
    static var fieldBackground: UIColor {
        return background.withAlphaComponent(0.6)
    }
}
