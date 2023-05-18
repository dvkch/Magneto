//
//  Action.swift
//  TorrentAdder
//
//  Created by syan on 18/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

struct Action {
    let title: String
    let icon: UIImage.Icon
    let color: UIColor
    let destructive: Bool
    let closure: () -> ()
    
    init(title: String, icon: UIImage.Icon, color: UIColor = .tint, destructive: Bool = false, closure: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.destructive = destructive
        self.closure = closure
    }
    
    var uiAction: UIAction {
        return UIAction(title: title, image: .icon(icon), attributes: destructive ? .destructive : []) { _ in
            closure()
        }
    }
    
    var uiContextualAction: UIContextualAction {
        let contextualAction = UIContextualAction(style: destructive ? .destructive : .normal, title: title) { _, _, completed in
            closure()
            completed(true)
        }
        contextualAction.image = .icon(icon)
        contextualAction.backgroundColor = color
        return contextualAction
    }
}
