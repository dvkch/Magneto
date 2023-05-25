//
//  NavigationController.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    convenience override init(rootViewController: UIViewController) {
        self.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        self.viewControllers = [rootViewController]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers.first?.loadViewIfNeeded()

        // https://stackoverflow.com/a/72505571/1439489
        if let scrollView = viewControllers.first?.view.subviews.first as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: -1), animated: false)
        }

        updateNavBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateNavBar()
    }
    
    private func updateNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
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
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 16.0, *) {
            navigationBar.preferredBehavioralStyle = .pad
        }
        #endif

        navigationBar.sizeToFit()
    }
}
