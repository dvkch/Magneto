//
//  NSObject+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import Foundation

extension NSObject {
    @objc(sy_className)
    static var className: String {
        return String(describing: self)
    }
    
    @objc(sy_className)
    var className: String {
        return String(describing: type(of: self))
    }
}

