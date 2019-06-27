//
//  Optional+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import Foundation

public protocol OptionalType {
    associatedtype Wrapped
    func map<U>(_ f: (Wrapped) throws -> U) rethrows -> U?
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: (Wrapped)? {
        switch self {
        case .none:             return nil
        case .some(let value):  return value
        }
    }
}
