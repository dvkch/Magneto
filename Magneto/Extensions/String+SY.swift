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
}
