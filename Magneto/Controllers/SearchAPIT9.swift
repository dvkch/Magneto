//
//  SearchAPIT9.swift
//  Magneto
//
//  Created by syan on 24/01/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import BrightFutures

// TODO: use mirrors
struct SearchAPIT9 {
    
    // MARK: Init
    static let shared = SearchAPIT9()
    private init() {}

    // MARK: Properties
    private let apiURL = URL(string: "https://www.torrent9.mn/")!

    // mirror list is super weird, not all websites work the same way... let's hope the current website works for a while :D
    private let mirrorConfig = SearchAPI.MirrorConfig(
        listURL: URL(string: "https://www.creativepixelmag.com/torrent9/")!,
        listScrapper: "t9_proxies",
        validatorScrapper: "t9_validator",
        expectedValue: "Torrent9"
    )
    
    // MARK: Methods
    func getWebMirrorURL() -> Future<URL, AppError> {
        // return SearchAPI.shared.getWebMirrorURL(config: mirrorConfig)
        return .init(value: apiURL)
    }
    
    func getResults(query: String, page: Int) -> Future<[SearchResultT9], AppError> {
        return SearchAPI.shared.getResults(
            mirror: apiURL,
            search: query,
            pathTemplate: ["recherche", nil, String(1 + 50 * page)],
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
