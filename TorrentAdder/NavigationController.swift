//
//  NavigationController.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = .textOverAccent
        navigationBar.barStyle = .blackOpaque
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.textOverAccent]
        updateColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }
    
    private func updateColors() {
        navigationBar.setBackgroundImage(UIImage(color: .accent), for: .default)
        navigationBar.setBackgroundImage(UIImage(color: .accent), for: .compact)
    }
}
