//
//  Array+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 28/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension Array where Element : Equatable {
    mutating func remove(_ element: Element) {
        while let index = index(of: element) {
            remove(at: index)
        }
    }
}

extension Array {
    func element(at index: Index) -> Element? {
        return index < count ? self[index] : nil
    }
}

