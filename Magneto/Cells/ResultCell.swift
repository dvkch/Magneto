//
//  ResultCell.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import SYKit

class ResultCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .cellBackground
    }

    // MARK: Properties
    var result: SearchResult? {
        didSet {
            updateContent()
        }
    }
    
    // MARK: Views
    @IBOutlet var label: UILabel!
    
    // MARK: Content
    private func updateContent() {
        guard let result else {
            label.text = nil
            return
        }
        var dateFont = UIFont.preferredFont(forTextStyle: .footnote)
        
        if result.recentness == .new {
            dateFont = UIFont.systemFont(ofSize: dateFont.pointSize, weight: .bold)
        }
        else if result.recentness == .recent {
            dateFont = UIFont.systemFont(ofSize: dateFont.pointSize, weight: .semibold)
        }
        
        let string = NSMutableAttributedString()
        string.append(result.name + "\n", font: .preferredFont(forTextStyle: .body), color: .normalText)
        string.append(result.size + ", ", font: .preferredFont(forTextStyle: .footnote), color: .altText)
        string.append(result.added + ", ", font: dateFont, color: .altText)
        string.append(String(result.seeders), font: .preferredFont(forTextStyle: .footnote), color: .seeder)
        string.append("/", font: .preferredFont(forTextStyle: .footnote), color: .gray)
        string.append(String(result.leechers), font: .preferredFont(forTextStyle: .footnote), color: .leechers)
        if result.verified {
            string.append(" ✔️", font: .preferredFont(forTextStyle: .caption2), color: nil)
        }
        
        label.attributedText = string
    }
}
