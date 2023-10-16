//
//  SearchResultTpb.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultTpb : SearchResult {
    // MARK: Properties
    let url: URL
    let name: String
    let magnet: URL
    let seeders: Int
    let leechers: Int
    let size: String
    let verified: Bool
    private let addedString: String
    private let addedDate: Date?

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case url = "url"
        case name = "name"
        case magnet = "magnet"
        case seeders = "seeders"
        case leechers = "leechers"
        case size = "size"
        case verified = "verified"
        case added = "added"
    }
    
    // "05-18 2022"
    private static let dateFormatterOld: DateFormatter = {
        let formatter = DateFormatter()
        formatter.defaultDate = Date()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "MM-dd yyyy"
        return formatter
    }()
    
    // "05-07 15:14"
    private static let dateFormatterRecent: DateFormatter = {
        let formatter = DateFormatter()
        formatter.defaultDate = Date()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter
    }()
    
    // "Today 06:53" & "Y-day 07:23"
    private static let dateFormatterToday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.defaultDate = Date()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private static func parseDate(string: String) -> Date? {
        let recentDate = string
            .replacingOccurrences(of: "Today", with: "")
            .replacingOccurrences(of: "Y-day", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return (
            dateFormatterOld.date(from: string) ??
            dateFormatterRecent.date(from: string) ??
            dateFormatterToday.date(from: recentDate)
        )
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        name = try container.decode(String.self, forKey: .name)
        magnet = try container.decode(URL.self, forKey: .magnet)
        seeders = (try container.decode(IntMaybeString.self, forKey: .seeders)).value
        leechers = (try container.decode(IntMaybeString.self, forKey: .leechers)).value
        size = try container.decode(String.self, forKey: .size)
        verified = try container.decode(Bool.self, forKey: .verified)
        addedString = try container.decode(String.self, forKey: .added)
        addedDate = SearchResultTpb.parseDate(string: addedString)
    }

    // MARK: URLs
    let pageURLAvailable: Bool = true

    func pageURL() -> Future<URL, AppError> {
        return .init(value: url)
    }

    func magnetURL() -> Future<URL, AppError> {
        return .init(value: magnet)
    }
    
    // MARK: Date
    var added: String {
        if let addedDate {
            return type(of: self).string(for: addedDate)
        }
        return addedString
    }
    
    var recentness: Recentness {
        if let addedDate {
            return type(of: self).recentness(for: addedDate)
        }
        return .new
    }
}
