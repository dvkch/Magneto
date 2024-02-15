//
//  SearchAPIT9.swift
//  Magneto
//
//  Created by syan on 24/01/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

// TODO: try using torrent9.mn
// TODO: use mirrors
struct SearchAPIT9 {
    
    // MARK: Init
    static let shared = SearchAPIT9()
    private init() {}

    // MARK: Properties
    let apiURL = URL(string: "https://www.torrent9.boo")!
    
    // MARK: Methods
    func getResults(query: String) -> Future<[SearchResultT9], AppError> {
        return SearchAPI.shared.getResults(
            mirror: apiURL,
            query: query,
            queryTemplate: ["recherche", nil],
            scrapper: "t9_results",
            type: SearchResultT9.self
        )
    }
    
    func getMagnet(result: SearchResultT9) -> Future<URL, AppError> {
        return SearchAPI.shared.getMagnet(for: result.resultPageURL, scrapper: "t9_magnet")
    }
}
