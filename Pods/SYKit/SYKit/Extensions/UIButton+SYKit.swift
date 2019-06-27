//
//  UIButton+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

public extension UIButton {
    @objc(sy_setBackgroundColor:forState:)
    func setBackgrounColor(_ color: UIColor?, for state: UIControl.State) {
        self.setBackgroundImage(UIImage(color: color), for: state)
    }
}
