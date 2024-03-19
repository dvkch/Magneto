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
    let apiURL = URL(string: "https://www.1337x.to")!
    
    // MARK: Methods
    func getResults(query: String, page: Int) -> Future<[SearchResultLeetx], AppError> {
        return SearchAPI.shared.getResults(
            mirror: apiURL,
            source: .content,
            search: query.replacingOccurrences(of: " ", with: " "),
            pathTemplate: ["search", nil, String(1 + page)],
            queryItems: nil,
            scrapper: "1337x_results",
            type: SearchResultLeetx.self
        )
    }
    
    private struct ResultPage: Codable {
        let url: URL
    }
    func getMagnet(pageURL: URL) -> Future<URL, AppError> {
        return SearchAPI.shared.getMagnet(for: pageURL, scrapper: "1337x_magnet")
    }
}
