//
//  UIScreen+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

public extension UIScreen {
    
    @objc(sy_boundsFixedToPortraitOrientation)
    var boundsFixedToPortraitOrientation: CGRect {
        return coordinateSpace.convert(bounds, to: fixedCoordinateSpace)
    }
}
