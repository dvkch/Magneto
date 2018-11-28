//
//  SYComputersCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

class SYComputersCell : UITableViewCell {
    
    // MARK: Views
    @IBOutlet private var addButton: SYButton!
    @IBOutlet private var label: UILabel!
    
    // MARK: Properties
    var addButtonTapBlock: (() -> Void)?
    var computersCount: Int = 0 {
        didSet {
            updateContent()
        }
    }
    
    // MARK: Actions
    @IBAction private func addButtonTap() {
        addButtonTapBlock?()
    }
    
    // MARK: Content
    private func updateContent() {
        switch computersCount {
        case 0:
            label.text = String(format: "No computers")
        case 1:
            label.text = String(format: "1 computer")
        default:
            label.text = String(format: "%d computers", computersCount)
        }
    }
}
