//
//  SearchResultT9.swift
//  Magneto
//
//  Created by syan on 24/01/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultT9 : SearchResult {

    // MARK: Properties
    let name: String
    let seeders: Int
    let leechers: Int
    let size: String
    let verified: Bool
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
        resultPageURL = T9API.shared.apiURL.appendingPathComponent(try container.decode(String.self, forKey: .resultPageURL))
    }

    // MARK: URLs
    let pageURLAvailable: Bool = true

    func pageURL() -> Future<URL, AppError> {
        return .init(value: resultPageURL)
    }

    func magnetURL() -> Future<URL, AppError> {
        return T9API.shared.getMagnet(result: self)
    }
    
    // MARK: Date
    var added: String {
        return ""
    }
    
    var recentness: Recentness {
        return .regular
    }
}
