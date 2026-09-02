//
//  SuggestionCell.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 12/07/2020.
//  Copyright © 2020 Syan.
//

import UIKit

class SuggestionCell: UITableViewCell {

    // MARK: Properties
    var suggestion: String? {
        didSet { label.text = suggestion }
    }

    // MARK: Views
    @IBOutlet private var label: UILabel!
}
