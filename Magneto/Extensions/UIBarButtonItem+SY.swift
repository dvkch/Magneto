//
//  UIBarButtonItem+SY.swift
//  Magneto
//
//  Created by syan on 18/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

// MARK: Common items
extension UIBarButtonItem {
    @available(iOS, obsoleted: 14.0, message: "Use navigationItem.backButtonDisplayMode = .minimal")
    static func back(title: String = "") -> UIBarButtonItem {
        return UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
    }
    
    static func loader(color: UIColor) -> UIBarButtonItem {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = color
        spinner.accessibilityLabel = L10n.Torrent.loading
        return UIBarButtonItem(customView: spinner)
    }
    
    static func close(target: Any, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.accessibilityLabel = L10n.Action.close
        button.backgroundColor = .normalText.withAlphaComponent(0.1)
        button.setImage(.icon(.close, variant: nil), for: .normal)
        button.tintColor = .altText
        button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: 1).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.layer.cornerRadius = 15
        button.addTarget(target, action: action, for: .primaryActionTriggered)
        return UIBarButtonItem(customView: button)
    }
    
    static func save(target: Any, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(image: .icon(.checkmark), style: .plain, target: target, action: action)
        button.title = L10n.Action.save
        return button
    }
}
