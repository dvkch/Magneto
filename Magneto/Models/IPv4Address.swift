//
//  IPv4Address.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

struct IPv4Address {

    // MARK: Init
    init?(string: String) {
        let parts = string.components(separatedBy: ".")
        guard parts.count == 4 else { return nil }
        
        let seg1 = Int(parts[0]) ?? 0
        let seg2 = Int(parts[1]) ?? 0
        let seg3 = Int(parts[2]) ?? 0
        let seg4 = Int(parts[3]) ?? 0
        
        var decimal: UInt32 = 0
        decimal |= UInt32((seg1 & 0xFF) << 24)
        decimal |= UInt32((seg2 & 0xFF) << 16)
        decimal |= UInt32((seg3 & 0xFF) <<  8)
        decimal |= UInt32((seg4 & 0xFF) <<  0)

        self.stringRepresentation = string
        self.decimalRepresentation = decimal
    }
    
    init?(decimal: UInt32) {
        let seg1 = (decimal >> 24) & 0xFF
        let seg2 = (decimal >> 16) & 0xFF
        let seg3 = (decimal >>  8) & 0xFF
        let seg4 = (decimal >>  0) & 0xFF
        
        self.decimalRepresentation = decimal
        self.stringRepresentation = [seg1, seg2, seg3, seg4].map { String($0) }.joined(separator: ".")
    }
    
    // MARK: Properties
    let decimalRepresentation: UInt32
    let stringRepresentation: String

    // MARK: Methods
    var isValidIP: Bool {
        let low = (decimalRepresentation >>  0) & 0xFF
        return low > 0 && low < 255
    }
}
