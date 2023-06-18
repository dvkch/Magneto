//
//  String+SY.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 13/07/2020.
//  Copyright © 2020 Syan. All rights reserved.
//

import Foundation

extension String {
    var magnetURL: URL? {
        return self
            .replacingOccurrences(of: " ", with: "%20")
            .url
    }
    
    func stringBetween(start: String, end: String) -> String? {
        let startRange = (self as NSString).range(of: start)
        let endRange   = (self as NSString).range(of: end)
        guard startRange.location != NSNotFound, endRange.location != NSNotFound else { return nil }
        let range = NSMakeRange(startRange.upperBound, endRange.lowerBound - startRange.upperBound)
        return (self as NSString).substring(with: range)
    }
}
