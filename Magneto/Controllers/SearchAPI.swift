//
//  SearchAPI.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import BrightFutures

protocol SearchAPI <SearchResult> {
    associatedtype SearchResult

    static var shared: Self { get }
    
    func getResults(query: String) -> Future<[SearchResult], AppError>
}


enum SearchAPIKind {
    case tpb
    case leetx
    
    var title: String {
        switch self {
        case .tpb:      return "The Pirate Bay"
        case .leetx:    return "1337x"
        }
    }
    
    var api: any SearchAPI {
        switch self {
        case .tpb:      return TpbAPI.shared
        case .leetx:    return LeetxAPI.shared
        }
    }
}
