//
//  SearchResultT9.swift
//  Magneto
//
//  Created by syan on 24/01/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultT9 : SearchResult, SearchResultVariant, Decodable {
    
    // MARK: Properties
    let name: String
    let size: String?
    let seeders: Int?
    let leechers: Int?
    let verified: Bool = false
    let addedString: String? = nil
    let addedDate: Date? = nil
    let resultPageURL: URL

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case size = "size"
        case seeders = "seeders"
        case leechers = "leechers"
        case resultPageURL = "url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name        = try container.decode(String.self, forKey: .name)
        size        = try container.decode(String.self, forKey: .size)
        seeders     = (try container.decode(IntMaybeString.self, forKey: .seeders)).value
        leechers    = (try container.decode(IntMaybeString.self, forKey: .leechers)).value
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
    
    // MARK: Variants
    func loadVariants() -> Future<(), AppError> {
        return .init(value: ())
    }
    
    var variants: [SearchResultVariant]? {
        return [self]
    }

    // MARK: Description
    var description: String {
        return "SearchResultT9: \(name), \(size ?? "<no size>")"
    }
}
