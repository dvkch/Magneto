//
//  NavigationBar.swift
//  Magneto
//
//  Created by syan on 18/05/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit
import SYKit

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
        
        animatedCirclesView.numberOfCircles = 3
        animatedCirclesView.backgroundColor = .darkTint.withAlphaComponent(0.6)
        animatedCirclesView.color = .normalTextOnTint.withAlphaComponent(0.3)
        animatedCirclesView.blurEffect = UIBlurEffect(style: .light)
        animatedCirclesView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animatedCirclesView)
        NSLayoutConstraint.activate([
            animatedCirclesView.topAnchor.constraint(equalTo: backgroundImageView.topAnchor),
            animatedCirclesView.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor),
            animatedCirclesView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor),
            animatedCirclesView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor)
        ])
    }

    // MARK: Views
    private let backgroundImageView = UIImageView()
    private let animatedCirclesView = AnimatedCirclesView()
    private var topConstraint: NSLayoutConstraint!
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        topConstraint.constant = -(window?.safeAreaInsets.top ?? 0)
        if subviews.firstIndex(of: backgroundImageView) != 0 {
            sendSubviewToBack(animatedCirclesView)
            sendSubviewToBack(backgroundImageView)
        }
    }
}
