//
//  UISearchBar+SYKit.swift
//  SYKit
//
//  Created by Stanislas Chevallier on 27/06/2019.
//  Copyright © 2019 Syan. All rights reserved.
//

import UIKit

public extension UISearchBar {
    
    @available(iOS, introduced: 9.0, deprecated: 13.0, message: "Use searchTextField instead")
    @available(macCatalyst, introduced: 9.0, deprecated: 13.1, message: "Use searchTextField instead")
    @objc(sy_textField)
    var textField: UITextField? {
        if #available(tvOS 9.0, *) {
            return findTextView(in: self, depth: 3)
        }
        #if !os(tvOS)
        if #available(iOS 13.0, macCatalyst 13.1, *) {
            return searchTextField
        }
        #endif
        if #available(iOS 13, *) {
            return findTextView(in: self, depth: 3)
        }
        return findTextView(in: self, depth: 2)
    }
    
    private func findTextView(in view: UIView, depth: Int) -> UITextField? {
        if let field = view as? UITextField { return field }
        guard depth > 0 else { return nil }
        return view.subviews.compactMap { findTextView(in: $0, depth: depth - 1) }.first
    }
}
