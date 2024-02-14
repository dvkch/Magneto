//
//  TagCell.swift
//  Magneto
//
//  Created by syan on 14/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 5
        contentView.layer.borderColor = UIColor.altText.cgColor
        contentView.layer.borderWidth = 1
        
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .altText
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    // MARK: Views
    private let label = UILabel()
}
