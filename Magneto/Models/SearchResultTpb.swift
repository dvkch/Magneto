//
//  SearchResultTpb.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultTpb : SearchResult, SearchResultVariant {

    // MARK: Properties
    let id: UUID
    let name: String
    let size: String?
    let seeders: Int?
    let leechers: Int?
    let verified: Bool
    let addedString: String?
    let addedDate: Date?
    let resultPageURL: URL
    let resultMagnetURL: URL

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case size = "size"
        case seeders = "seeders"
        case leechers = "leechers"
        case verified = "verified"
        case addedString = "added"
        case addedDate = "added_parsed"
        case resultPageURL = "url"
        case resultMagnetURL = "magnet"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id              = UUID()
        name            = try container.decode(String.self, forKey: .name)
        size            = try container.decode(String.self, forKey: .size)
        seeders         = (try container.decode(IntMaybeString.self, forKey: .seeders)).value
        leechers        = (try container.decode(IntMaybeString.self, forKey: .leechers)).value
        verified        = try container.decode(Bool.self, forKey: .verified)
        addedString     = try container.decode(String.self, forKey: .addedString)
        addedDate       = try container.decode(Date.self, forKey: .addedDate)
        resultPageURL   = try container.decode(URL.self, forKey: .resultPageURL)
        resultMagnetURL = try container.decode(URL.self, forKey: .resultMagnetURL)
    }

    // MARK: URLs
    let pageURLAvailable: Bool = true

    func pageURL() -> Future<URL, AppError> {
        return .init(value: resultPageURL)
    }

    func torrent() -> Future<Torrent, AppError> {
        return .init(value: .url(resultMagnetURL))
    }
    
    // MARK: Variants
    func loadVariants() -> Future<(), AppError> {
        return .init(value: ())
    }
    
    var variants: [SearchResultVariant]? {
        return [self]
    }

    // MARK: Description
    var description: String {
        return "SearchResultTpb: \(name), \(size ?? "<no size>")"
    }
}
