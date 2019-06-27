//
//  UIViewController+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import UIKit

public extension UIViewController {
    @objc(sy_isModal)
    var sy_isModal: Bool {
        // http://stackoverflow.com/questions/2798653/is-it-possible-to-determine-whether-viewcontroller-is-presented-as-modal/16764496#16764496
        return presentingViewController?.presentedViewController == self
            || (navigationController != nil && navigationController?.presentingViewController?.presentedViewController == navigationController)
            || tabBarController?.presentingViewController?.isKind(of: UITabBarController.self) == true

    }
}
