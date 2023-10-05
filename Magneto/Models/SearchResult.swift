//
//  SearchResult.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Foundation
import BrightFutures

enum Recentness {
    case new, recent, regular
}

protocol SearchResult: Decodable, CustomStringConvertible {
    // MARK: Stored properties
    var name: String    { get }
    var seeders: Int    { get }
    var leechers: Int   { get }
    var size: String    { get }
    var verified: Bool  { get }

    var added: String       { get }
    var recentness: Recentness  { get }
    
    // MARK: Computed properties
    var pageURLAvailable: Bool { get }
    func pageURL() -> Future<URL, AppError>
    func magnetURL() -> Future<URL, AppError>
}

extension SearchResult {
    var description: String {
        return "Result: \(name), \(size), \(added), \(seeders)/\(leechers), vip=\(verified)"
    }
}

extension SearchResult {
    static func string(for added: Date) -> String {
        if Date().timeIntervalSince(added) > 1440 * 3600 { // two months
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: added)
        }
        else {
            let formatter = RelativeDateTimeFormatter()
            formatter.dateTimeStyle = .numeric
            formatter.unitsStyle = .full
            return formatter.localizedString(for: added, relativeTo: Date())
        }
    }
    
    static func recentness(for added: Date) -> Recentness {
        if fabs(added.timeIntervalSinceNow) < 48 * 3600 {
            return .new
        }
        else if fabs(added.timeIntervalSinceNow) < 360 * 3600 {
            return .recent
        }
        else {
            return .regular
        }
    }
}
