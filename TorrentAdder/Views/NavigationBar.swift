//
//  NavigationBar.swift
//  TorrentAdder
//
//  Created by syan on 18/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.clipsToBounds = true
        addSubview(backgroundImageView)

        topConstraint = backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor)
        NSLayoutConstraint.activate([
            topConstraint,
            backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    // MARK: Views
    private let backgroundImageView = UIImageView()
    private var topConstraint: NSLayoutConstraint!
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        topConstraint.constant = -(window?.safeAreaInsets.top ?? 0)
        if subviews.firstIndex(of: backgroundImageView) != 0 {
            sendSubviewToBack(backgroundImageView)
        }
    }
}
