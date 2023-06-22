//
//  SearchResultLeetx.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultLeetx : SearchResult {

    // MARK: Properties
    let name: String
    let seeders: Int
    let leechers: Int
    let size: String
    let verified: Bool
    let added: Date
    let resultPageURL: URL

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case seeders = "seeders"
        case leechers = "leechers"
        case size = "size"
        case added = "added"
        case resultPageURL = "url"
    }
    
    // "Jul. 7th '22"
    private static let dateFormatterOld: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "MMM dd yy"
        return formatter
    }()
    
    // "7am Jun. 15th"
    private static let dateFormatterRecent: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "ha MM dd yyyy"
        return formatter
    }()
    
    private static func parseDate(string: String) -> Date? {
        let cleanedUp = string
            .replacingOccurrences(of: "st", with: "")
            .replacingOccurrences(of: "nd", with: "")
            .replacingOccurrences(of: "rd", with: "")
            .replacingOccurrences(of: "th", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        let currentYear = Calendar.current.component(.year, from: Date())
        return dateFormatterOld.date(from: cleanedUp) ?? dateFormatterRecent.date(from: cleanedUp + " \(currentYear)")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        seeders = (try container.decode(IntMaybeString.self, forKey: .seeders)).value
        leechers = (try container.decode(IntMaybeString.self, forKey: .leechers)).value
        size = try container.decode(String.self, forKey: .size)
        verified = false
        
        let dateString = (try container.decode(String.self, forKey: .added))
        added = SearchResultLeetx.parseDate(string: dateString) ?? Date(timeIntervalSince1970: 0)
        resultPageURL = LeetxAPI.shared.apiURL.appendingPathComponent(try container.decode(String.self, forKey: .resultPageURL))
    }

    // MARK: URLs
    let pageURLAvailable: Bool = true

    func pageURL() -> Future<URL, AppError> {
        return .init(value: resultPageURL)
    }

    func magnetURL() -> Future<URL, AppError> {
        return LeetxAPI.shared.getMagnet(result: self)
    }
}
