//
//  String+SYKit.swift
//  Pods-SYKitExample
//
//  Created by Stanislas Chevallier on 27/06/2019.
//

import Foundation

public extension StringProtocol {
    var localized: String {
        return NSLocalizedString(String(self), comment: String(self))
    }
    
    func firstLines(_ count: Int) -> String {
        var lines = components(separatedBy: .newlines)
        if lines.count > count {
            lines = Array(lines[0..<count])
        }
        return lines.joined(separator: "\n")
    }
}

public extension String {
    var url: URL? {
        return URL(string: self)
    }
}
