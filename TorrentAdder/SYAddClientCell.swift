//
//  SYAddClientCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

class SYAddClientCell : UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.textColor = .text
    }
    
    // MARK: Views
    @IBOutlet private var addButton: AddButton!
    @IBOutlet private var label: UILabel!
    
    // MARK: Properties
    var addButtonTapBlock: (() -> Void)?
    var clientsCount: Int = 0 {
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
        switch clientsCount {
        case 0: label.text = "clients.count.add".localized
        case 1: label.text = "clients.count.1".localized
        default:label.text = String(format: "clients.count.%d".localized, clientsCount)
        }
    }
}
