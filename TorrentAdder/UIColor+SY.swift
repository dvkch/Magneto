//
//  UIColor+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
    }
    
    static var accent: UIColor {
        let light = UIColor(red: 64 / 255, green: 146 / 255, blue: 247 / 255, alpha: 1)
        let dark  = UIColor(red:  0 / 255, green: 106 / 255, blue: 230 / 255, alpha: 1)
        return UIColor(light: light, dark: dark)
    }
    
    static var seeder: UIColor {
        return UIColor(red: 0.39, green: 0.79, blue: 0.34, alpha: 1)
    }

    static var leechers: UIColor {
        return .red
    }
    
    static var text: UIColor {
        return UIColor(light: .black, dark: .white)
    }
    
    static var subtext: UIColor {
        return UIColor(light: .darkGray, dark: .darkGray)
    }
    
    static var fieldBackground: UIColor {
        return background.withAlphaComponent(0.6)
    }
    
    static var textOverAccent: UIColor {
        return .white
    }
    
    static var separator: UIColor {
        return UIColor(light: UIColor(white: 0.85, alpha: 1), dark: .darkGray)
    }
    
    static var background: UIColor {
        return systemBackground
    }
    
    static var basicAction: UIColor {
        return .separator
    }
    
    static var destructiveAction: UIColor {
        return .red
    }
}
