//
//  UISearchBar+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

public extension UISearchBar {
    
    @objc(sy_textField)
    var textField: UITextField? {
        
        for subview in subviews {
            if subview.isKind(of: UITextField.self) {
                return subview as? UITextField
            }
            
            for subsubview in subview.subviews {
                if subsubview.isKind(of: UITextField.self) {
                    return subsubview as? UITextField
                }
            }
        }
        
        return nil
    }
}
