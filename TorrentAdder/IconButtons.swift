//
//  IconButton.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 27/06/2019.
//  Copyright © 2019 Syan. All rights reserved.
//

import UIKit

class AddButton: UIButton {
    
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
        backgroundColor = .lightBlue
        setImage(UIImage(named: "button_add")?.masking(with: .white), for: .normal)
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = .init(width: 3, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

class HelpButton: UIButton {
    
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
        backgroundColor = .white
        setImage(UIImage(named: "button_help")?.masking(with: .lightBlue), for: .normal)

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = .init(width: 3, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 1
    }
    
    // MARK: Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
