//
//  SYResultCell.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import NSDate_TimeAgo
import SYKit

class SYResultCell: UITableViewCell {

    // MARK: Properties
    var result: SYSearchResult? {
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
        var dateFont = UIFont.systemFont(ofSize: 14)
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
        
        string.append(result.name + "\n", font: UIFont.systemFont(ofSize: 16), color: .text)
        if let size = result.size {
            string.append(size + ", ", font: UIFont.systemFont(ofSize: 15), color: .subtext)
        }
        string.append(dateString + ", ", font: dateFont, color: .subtext)
        string.append(String(result.seed), font: UIFont.systemFont(ofSize: 14), color: .seeder)
        string.append("/", font: UIFont.systemFont(ofSize: 14), color: .gray)
        string.append(String(result.leech), font: UIFont.systemFont(ofSize: 14), color: .leechers)
        if result.verified {
            string.append(" ✔️", font: UIFont.systemFont(ofSize: 12), color: nil)
        }
        
        label.attributedText = string
    }
}
