//
//  SearchResultYts.swift
//  Magneto
//
//  Created by syan on 13/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultYts : SearchResult, Decodable {

    // MARK: Properties
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
        return YtsAPI.shared.loadVariants(result: self)
    }
    
    var variants: [any SearchResultVariant]? {
        return YtsAPI.shared.variants(for: self)?.map { $0 as any SearchResultVariant }
    }
    
    // MARK: Description
    var description: String {
        return "SearchResultYts: \(name)"
    }
}

struct SearchResultVariantYts : SearchResultVariant, Decodable {

    // MARK: Properties
    let name: String
    let size: String? = nil
    
    let seeders: Int? = nil
    let leechers: Int? = nil
    
    let downloadURL: URL

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case downloadURL = "url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name          = try container.decode(String.self, forKey: .name)
        downloadURL   = try container.decode(URL.self, forKey: .downloadURL)
    }

    // MARK: URLs
    func magnetURL() -> Future<URL, AppError> {
        return .init(value: downloadURL)
    }
    
    // MARK: Description
    var description: String {
        return "SearchResultVariantYts: \(name), \(downloadURL)"
    }
}

