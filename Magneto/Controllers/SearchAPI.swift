//
//  SearchAPI.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import BrightFutures

protocol SearchAPI <Result> {
    associatedtype Result: SearchResult

    static var shared: Self { get }
    
    func getResults(query: String) -> Future<[Result], AppError>
}

enum SearchAPIKind: String, Codable, Equatable, CaseIterable {
    case tpb = "tpb"
    case leetx = "leetx"
    
    var title: String {
        switch self {
        case .tpb:      return "The Pirate Bay"
        case .leetx:    return "1337x"
        }
    }
    
    var icon: UIImage.Icon {
        switch self {
        case .tpb:      return .sailboat
        case .leetx:    return .cloud
        }
    }
}
