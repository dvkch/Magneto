//
//  ResultCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import NSDate_TimeAgo
import SYKit

class ResultCell: UITableViewCell {

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
        guard let result = result else {
            label.text = nil
            return
        }
        
        var dateString = result.age ?? ""
        var dateFont = UIFont.preferredFont(forTextStyle: .caption1)
        if let date = result.parsedDate {
            let twoMonths: TimeInterval = 1440 * 3600
            dateString = (date as NSDate).timeAgo(withLimit: twoMonths, dateFormat: .medium, andTimeFormat: .none)
            
            if fabs(date.timeIntervalSinceNow) < 48 * 3600 {
                dateFont = UIFont.systemFont(ofSize: 14, weight: .bold)
            }
            else if fabs(date.timeIntervalSinceNow) < 360 * 3600 {
                dateFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
            }
        }
        
        let string = NSMutableAttributedString()
        
        string.append(result.name + "\n", font: .preferredFont(forTextStyle: .body), color: .text)
        if let size = result.size {
            string.append(size + ", ", font: .preferredFont(forTextStyle: .body), color: .subtext)
        }
        string.append(dateString + ", ", font: dateFont, color: .subtext)
        string.append(String(result.seed), font: .preferredFont(forTextStyle: .caption1), color: .seeder)
        string.append("/", font: .preferredFont(forTextStyle: .caption1), color: .gray)
        string.append(String(result.leech), font: .preferredFont(forTextStyle: .caption1), color: .leechers)
        if result.verified {
            string.append(" ✔️", font: .preferredFont(forTextStyle: .caption2), color: nil)
        }
        
        label.attributedText = string
    }
}
