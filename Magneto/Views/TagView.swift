//
//  TagView.swift
//  Magneto
//
//  Created by syan on 30/03/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import UIKit
import SYKit

class TagView: SYKit.TagView {
    override func setup() {
        super.setup()
        layer.borderColor = UIColor.altText.cgColor
        setBackgroundColor(.altText, for: .highlighted)
        setTitleColor(.altText, for: .normal)
        setTitleColor(.backgroundAlt, for: .highlighted)
    }

}
