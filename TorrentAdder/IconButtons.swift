//
//  IconButton.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 27/06/2019.
//  Copyright © 2019 Syan. All rights reserved.
//

import UIKit

class IconButton: UIButton {
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
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
        
        updateStyle()
    }
    
    // MARK: Style
    func updateStyle() {
        layer.shadowColor = traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.2, alpha: 1).cgColor : UIColor.gray.cgColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateStyle()
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

class AddButton: IconButton {
    // MARK: Style
    override func updateStyle() {
        super.updateStyle()
        layer.shadowOffset = .init(width: 0, height: 0)
        backgroundColor = .accent
        setImage(UIImage(named: "button_add")?.masking(with: .textOverAccent), for: .normal)
    }
}

class HelpButton: IconButton {
    // MARK: Style
    override func updateStyle() {
        super.updateStyle()
        layer.shadowOffset = .init(width: 2, height: 2)
        backgroundColor = .textOverAccent
        setImage(UIImage(named: "button_help")?.masking(with: .accent), for: .normal)
    }
}
