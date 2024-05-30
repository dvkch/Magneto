//
//  Strings+SY.swift
//  Magneto
//
//  Created by syan on 30/05/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation

protocol L10nQuantity {
    static var zero: String { get }
    static var one: String { get }
    static func other(_ count: Int) -> String
}

extension L10nQuantity {
    static func quantity(_ count: Int) -> String {
        switch count {
        case 0: zero
        case 1: one
        default: other(count)
        }
    }
}

extension L10n.Torrent.Removed: L10nQuantity {}
