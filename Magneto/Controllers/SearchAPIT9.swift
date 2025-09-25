//
//  SearchAPIT9.swift
//  Magneto
//
//  Created by syan on 24/01/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchAPIT9 {
    
    // MARK: Init
    static let shared = SearchAPIT9()
    private init() {}

    // MARK: Properties
    // mirror list for next time: https://www.creativepixelmag.com/torrent9/
    private let apiURL = URL(string: "https://www.torrent9.fyi/")!
    
    // MARK: Methods
    func getWebMirrorURL() -> Future<URL, AppError> {
        return .init(value: apiURL)
    }
    
    func getResults(query: String, page: Int) -> Future<[SearchResultT9], AppError> {
        return SearchAPI.shared.getResults(
            mirror: apiURL,
            search: query,
            pathTemplate: ["recherche", nil, "\(page * 50 + 1)"],
            queryItems: nil,
            scrapper: "t9_results",
            type: SearchResultT9.self
        )
    }
    
    func getMagnet(result: SearchResultT9) -> Future<Torrent, AppError> {
        return result.pageURL().flatMap { pageURL in
            return SearchAPI.shared.getTorrent(for: pageURL, scrapper: "t9_magnet")
        }
    }
}
