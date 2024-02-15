//
//  SearchAPIYts.swift
//  Magneto
//
//  Created by syan on 13/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchAPIYts {
    
    // MARK: Init
    static let shared = SearchAPIYts()
    private init() {}
    
    // MARK: Properties
    private let apiURL = URL(string: "https://yts.mx")!
    
    // MARK: Methods
    func getResults(query: String) -> Future<[SearchResultYts], AppError> {
        return SearchAPI.shared.getResults(
            mirror: apiURL,
            query: query,
            queryTemplate: ["browse-movies", nil],
            scrapper: "yts_results",
            type: SearchResultYts.self
        )
    }
    
    func cachedVariants(for result: SearchResultYts) -> [SearchResultVariantYts]? {
        return SearchAPI.shared.cachedVariants(for: result.resultPageURL, type: SearchResultVariantYts.self)
    }

    func loadVariants(for result: SearchResultYts) -> Future<(), AppError> {
        return SearchAPI.shared.loadVariants(for: result.resultPageURL, scrapper: "yts_variants", type: SearchResultVariantYts.self)
    }
}
