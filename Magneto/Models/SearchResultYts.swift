//
//  SearchResultYts.swift
//  Magneto
//
//  Created by syan on 13/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultYts : SearchResult {

    // MARK: Properties
    let id: UUID
    let name: String
    let verified: Bool = true
    let addedString: String? = nil
    let addedDate: Date? = nil
    let resultPageURL: URL

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case resultPageURL = "url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id              = UUID()
        name            = try container.decode(String.self, forKey: .name)
        resultPageURL   = try container.decode(URL.self, forKey: .resultPageURL)
    }

    // MARK: URLs
    let pageURLAvailable: Bool = true

    func pageURL() -> Future<URL, AppError> {
        return .init(value: resultPageURL)
    }

    // MARK: Variants
    func loadVariants() -> Future<(), AppError> {
        return SearchAPIYts.shared.loadVariants(for: self)
    }
    
    var variants: [any SearchResultVariant]? {
        return SearchAPIYts.shared.cachedVariants(for: self) as [any SearchResultVariant]?
    }
    
    // MARK: Description
    var description: String {
        return "SearchResultYts: \(name)"
    }
}

struct SearchResultVariantYts : SearchResultVariant, Decodable {

    // MARK: Properties
    let name: String
    let size: String?
    
    let seeders: Int? = nil
    let leechers: Int? = nil
    
    let torrentBase64: String?
    let downloadURL: URL

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case downloadURL = "url"
        case torrentBase64 = "torrent"
        case size = "size"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name          = try container.decode(String.self, forKey: .name)
        downloadURL   = try container.decode(URL.self, forKey: .downloadURL)
        torrentBase64 = try container.decodeIfPresent(String.self, forKey: .torrentBase64)
        size          = try container.decodeIfPresent(String.self, forKey: .size)
    }

    // MARK: URLs
    func torrent() -> Future<Torrent, AppError> {
        if let torrentBase64 {
            return .init(value: .base64(downloadURL, torrentBase64))
        }
        return .init(value: .url(downloadURL))
    }
    
    // MARK: Description
    var description: String {
        return "SearchResultVariantYts: \(name), \(downloadURL)"
    }
}

