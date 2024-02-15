//
//  SearchAPIKind.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import UIKit

enum SearchAPIKind: String, Codable, Equatable, CaseIterable {
    case tpb = "tpb"
    case leetx = "leetx"
    case t9 = "t9"
    case yts = "yts"
    
    var title: String {
        switch self {
        case .tpb:      return "The Pirate Bay"
        case .leetx:    return "1337x"
        case .t9:       return "Torrent9"
        case .yts:      return "YTS"
        }
    }
    
    var icon: UIImage.Icon {
        switch self {
        case .tpb:      return .sailboat
        case .leetx:    return .cloud
        case .t9:       return .nine
        case .yts:      return .film
        }
    }
}
