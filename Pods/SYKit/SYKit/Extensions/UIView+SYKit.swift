//
//  UIView+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

public extension UIView {

    @objc(sy_findSubviewsOfClass:recursive:)
    @available(swift, obsoleted: 1.0)
    func objc_subviews(ofKind clazz: AnyClass, recursive: Bool) -> [UIView] {
        guard let t = clazz as? UIView.Type else { return [] }
        return subviews(ofKind: t, recursive: recursive)
    }

    func subviews<T: UIView>(ofKind clazz: T.Type, recursive: Bool) -> [T] {
        var result = [T]()
        
        for subview in subviews {
            // need to do both tests, because when calling from objc_subviews(ofKing:recursive:) we will have clazz of the requested type, but T will UIView
            if subview.isKind(of: clazz), let subview = subview as? T {
                result.append(subview)
            }
            
            if recursive {
                result.append(contentsOf: subview.subviews(ofKind: clazz, recursive: recursive))
            }
        }
        return result
    }

    var safeAreaBounds: CGRect {
        var value = bounds
        #if os(iOS)
        if #available(iOS 11.0, *) {
            value = value.inset(by: safeAreaInsets)
        }
        #elseif os(tvOS)
        if #available(tvOS 11.0, *) {
            value = value.inset(by: safeAreaInsets)
        }
        #endif
        return value
    }
}
