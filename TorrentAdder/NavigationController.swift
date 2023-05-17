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
        updateNavBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateNavBar()
    }
    
    private func updateNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .accent
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textOverAccent]

        navigationBar.standardAppearance = appearance
        navigationBar.tintColor = .textOverAccent
        navigationBar.prefersLargeTitles = false
    }
}
