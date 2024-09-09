//
//  SearchResultT9.swift
//  Magneto
//
//  Created by syan on 24/01/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultT9 : SearchResult, SearchResultVariant {
    
    // MARK: Properties
    let id: UUID
    let name: String
    let size: String?
    let seeders: Int?
    let leechers: Int?
    let verified: Bool = false
    let addedString: String? = nil
    let addedDate: Date? = nil
    private let pagePath: String

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case size = "size"
        case seeders = "seeders"
        case leechers = "leechers"
        case pagePath = "url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id          = UUID()
        name        = try container.decode(String.self, forKey: .name)
        size        = try container.decodeIfPresent(String.self, forKey: .size)
        seeders     = (try container.decodeIfPresent(IntMaybeString.self, forKey: .seeders))?.value
        leechers    = (try container.decodeIfPresent(IntMaybeString.self, forKey: .leechers))?.value
        pagePath    = try container.decode(String.self, forKey: .pagePath)
    }
    
    // MARK: URLs
    let pageURLAvailable: Bool = false
    
    func pageURL() -> Future<URL, AppError> {
        return SearchAPIT9.shared.getWebMirrorURL().map { $0.appendingPathComponent(pagePath) }
    }
    
    func torrent() -> Future<Torrent, AppError> {
        return SearchAPIT9.shared.getMagnet(result: self)
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
