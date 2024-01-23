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
    private let addedParsed: Date?

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
        case addedParsed = "added_parsed"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url         = try container.decode(URL.self, forKey: .url)
        name        = try container.decode(String.self, forKey: .name)
        magnet      = try container.decode(URL.self, forKey: .magnet)
        seeders     = (try container.decode(IntMaybeString.self, forKey: .seeders)).value
        leechers    = (try container.decode(IntMaybeString.self, forKey: .leechers)).value
        size        = try container.decode(String.self, forKey: .size)
        verified    = try container.decode(Bool.self, forKey: .verified)
        addedString = try container.decode(String.self, forKey: .added)
        addedParsed = try container.decode(Date.self, forKey: .addedParsed)
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
