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
    private let addedString: String
    private let addedParsed: Date?
    let resultPageURL: URL

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case seeders = "seeders"
        case leechers = "leechers"
        case size = "size"
        case added = "added"
        case addedParsed = "added_parsed"
        case resultPageURL = "url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name        = try container.decode(String.self, forKey: .name)
        seeders     = (try container.decode(IntMaybeString.self, forKey: .seeders)).value
        leechers    = (try container.decode(IntMaybeString.self, forKey: .leechers)).value
        size        = try container.decode(String.self, forKey: .size)
        verified    = false
        addedString = try container.decode(String.self, forKey: .added)
        addedParsed = try container.decode(Date.self, forKey: .addedParsed)
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
    
    // MARK: Date
    var added: String {
        if let addedParsed {
            return type(of: self).string(for: addedParsed)
        }
        return addedString
    }
    
    var recentness: Recentness {
        if let addedParsed {
            return type(of: self).recentness(for: addedParsed)
        }
        return .new
    }
}
