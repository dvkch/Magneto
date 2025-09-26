//
//  SearchAPILeetx.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchAPILeetx {
    
    // MARK: Init
    static let shared = SearchAPILeetx()
    private init() {}
    
    // MARK: Properties
    let apiURL = URL(string: "https://1337x.to")!
    
    // MARK: Methods
    func getResults(query: String, page: Int) -> Future<[SearchResultLeetx], AppError> {
        return SearchAPI.shared.getResults(
            mirror: apiURL,
            source: .content, // Hapier is somewhat able to circumvent potential CF protections, but it still is faster to do on-device
            search: query.replacingOccurrences(of: " ", with: " "),
            pathTemplate: ["search", nil, String(1 + page), ""], // needs to end with a /
            queryItems: nil,
            scrapper: "1337x_results",
            type: SearchResultLeetx.self
        )
    }
    
    func getMagnet(pageURL: URL) -> Future<Torrent, AppError> {
        return SearchAPI.shared.getTorrent(for: pageURL, source: .content, scrapper: "1337x_magnet")
    }
}
