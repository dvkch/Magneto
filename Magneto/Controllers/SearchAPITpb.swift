//
//  SearchAPITpb.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 29/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import BrightFutures

struct SearchAPITpb {
    
    // MARK: Init
    static let shared = SearchAPITpb()
    private init() {}
    
    // MARK: Properties
    private let mirrorConfig = SearchAPI.MirrorConfig(
        listURL: URL(string: "https://piratebayproxy.info/")!,
        listScrapper: "tpb_proxies",
        validatorScrapper: "tpb_validator",
        expectedValue: "The Pirate Bay"
    )
    
    // MARK: Methods
    func getWebMirrorURL() -> Future<URL, AppError> {
        return SearchAPI.shared.getWebMirrorURL(config: mirrorConfig)
    }
    
    func getResults(query: String, page: Int) -> Future<[SearchResultTpb], AppError> {
        return SearchAPI.shared.getResults(
            config: mirrorConfig,
            search: query,
            pathTemplate: ["search", nil, String(1 + page), "99", "0"],
            queryItems: nil,
            scrapper: "tpb_results",
            type: SearchResultTpb.self
        )
    }
}
