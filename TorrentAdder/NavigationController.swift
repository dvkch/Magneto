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
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .accent
            appearance.titleTextAttributes = [.foregroundColor: UIColor.textOverAccent]

            navigationBar.standardAppearance = appearance
            navigationBar.tintColor = .textOverAccent
            navigationBar.prefersLargeTitles = false
        }
        else {
            navigationBar.prefersLargeTitles = false
            navigationBar.isTranslucent = false
            navigationBar.setBackgroundImage(UIImage(color: .accent), for: .default)
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.textOverAccent]
            navigationBar.tintColor = .textOverAccent
            navigationBar.barTintColor = .clear
        }
    }
}
