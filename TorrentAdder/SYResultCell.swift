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
        
        string.sy_appendString(result.name + "\n", font: UIFont.systemFont(ofSize: 16), color: .darkText)
        if let size = result.size {
            string.sy_appendString(size + ", ", font: UIFont.systemFont(ofSize: 15), color: .gray)
        }
        string.sy_appendString(dateString + ", ", font: dateFont, color: .gray)
        // TODO: add color in extension
        string.sy_appendString(String(result.seed), font: UIFont.systemFont(ofSize: 14), color: .seedGreen)
        string.sy_appendString("/", font: UIFont.systemFont(ofSize: 14), color: .gray)
        string.sy_appendString(String(result.leech), font: UIFont.systemFont(ofSize: 14), color: .red)
        if result.verified {
            string.sy_appendString(" ✔️", font: UIFont.systemFont(ofSize: 12), color: .blue)
        }
        
        label.attributedText = string
    }
}