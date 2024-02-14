//
//  SearchResultLeetx.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultLeetx : SearchResult, SearchResultVariant, Decodable {

    // MARK: Properties
    let name: String
    let size: String?
    let seeders: Int?
    let leechers: Int?
    let verified: Bool = false
    let addedString: String?
    let addedDate: Date?
    let resultPageURL: URL

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case size = "size"
        case seeders = "seeders"
        case leechers = "leechers"
        case addedString = "added"
        case addedDate = "added_parsed"
        case resultPageURL = "url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name        = try container.decode(String.self, forKey: .name)
        size        = try container.decode(String.self, forKey: .size)
        seeders     = (try container.decode(IntMaybeString.self, forKey: .seeders)).value
        leechers    = (try container.decode(IntMaybeString.self, forKey: .leechers)).value
        addedString = try container.decode(String.self, forKey: .addedString)
        addedDate   = try container.decode(Date.self, forKey: .addedDate)
        resultPageURL = LeetxAPI.shared.apiURL.appendingPathComponent(try container.decode(String.self, forKey: .resultPageURL))
    }

    // MARK: URLs
    let pageURLAvailable: Bool = true

    func pageURL() -> Future<URL, AppError> {
        return .init(value: resultPageURL)
    }

    func magnetURL() -> BrightFutures.Future<URL, AppError> {
        return LeetxAPI.shared.getMagnet(pageURL: resultPageURL)
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
        return "SearchResultLeetx: \(name), \(size ?? "<no size>")"
    }
}
