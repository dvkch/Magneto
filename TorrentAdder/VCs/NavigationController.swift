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
    
    var useClearNavBarBackground: Bool = false {
        didSet {
            updateNavBar()
        }
    }
    
    private func updateNavBar() {
        let appearance = UINavigationBarAppearance()
        if useClearNavBarBackground {
            appearance.configureWithTransparentBackground()
        }
        else {
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = .tint
        }
        appearance.titleTextAttributes = [.foregroundColor: UIColor.normalTextOnTint]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.normalTextOnTint]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }

        navigationBar.tintColor = .normalTextOnTint
        navigationBar.prefersLargeTitles = true
        
        navigationBar.setBackButtonImage(.icon(.left))
    }
}
