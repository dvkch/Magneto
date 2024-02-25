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

protocol SearchResult: CustomStringConvertible, Decodable, Identifiable {
    var id: UUID { get }
    
    var name: String    { get }
    var verified: Bool  { get }

    var addedString: String?    { get }
    var addedDate: Date?        { get }
    var recentness: Recentness? { get }

    var pageURLAvailable: Bool  { get }
    func pageURL() -> Future<URL, AppError>
    
    func loadVariants() -> Future<(), AppError>
    var variants: [any SearchResultVariant]? { get }
    var uniqueVariant: SearchResultVariant? { get }
}

extension SearchResult {
    var added: String? {
        if let addedDate {
            if Date().timeIntervalSince(addedDate) > 1440 * 3600 { // two months
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: addedDate)
            }
            else {
                let formatter = RelativeDateTimeFormatter()
                formatter.dateTimeStyle = .numeric
                formatter.unitsStyle = .full
                return formatter.localizedString(for: addedDate, relativeTo: Date())
            }
        }

        return addedString
    }
    
    var recentness: Recentness? {
        if let addedDate {
            if fabs(addedDate.timeIntervalSinceNow) < 48 * 3600 {
                return .new
            }
            else if fabs(addedDate.timeIntervalSinceNow) < 360 * 3600 {
                return .recent
            }
        }
        return .regular
    }
    
    var uniqueVariant: SearchResultVariant? {
        return variants?.unique
    }
}

protocol SearchResultVariant: CustomStringConvertible, Decodable, Taggable {
    var name: String    { get }
    var size: String?   { get }
    
    var seeders: Int?   { get }
    var leechers: Int?  { get }
    
    func magnetURL() -> Future<URL, AppError>
}

extension SearchResultVariant {
    var tag: String {
        return name.uppercased()
    }
}
