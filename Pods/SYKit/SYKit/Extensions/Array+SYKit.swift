//
//  Array+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 26/06/2019.
//

import Foundation

public extension Array where Element : Equatable {
    mutating func remove(element: Element) {
        while let index = self.firstIndex(of: element) {
            self.remove(at: index)
        }
    }
    
    func after(_ element: Element) -> Element? {
        guard let index = self.firstIndex(of: element) else { return nil }
        if index + 1 >= count {
            return first
        }
        return self[index + 1]
    }
}

public extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var nilIfEmpty: Self? {
        return isEmpty ? nil : self
    }
}

public extension Array where Element : OptionalType {
    func removingNils() -> [Element.Wrapped] {
        return compactMap { $0.value }
    }
}

public extension Collection {
    func subarray(maxCount: Int) -> Self.SubSequence {
        let max = Swift.min(maxCount, count)
        let maxIndex = index(startIndex, offsetBy: max)
        return self[startIndex..<maxIndex]
    }
}
