//
//  Codable+SY.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 03/12/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

struct IntMaybeString: Decodable {
    private(set) var value: Int = 0

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self), let intValue = Int(stringValue) {
            value = intValue
        }
        else {
            value = try container.decode(Int.self)
        }
    }
}
