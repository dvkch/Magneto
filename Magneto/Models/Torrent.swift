//
//  Torrent.swift
//  Magneto
//
//  Created by syan on 13/05/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import Bencode

enum Torrent {
    case url(URL)
    case base64(URL, String)
}

extension Torrent {
    var name: String? {
        switch self {
        case .url(let url):
            return url.magnetName?.capitalized
        case .base64(_, let base64):
            let content = Data(base64Encoded: base64) ?? Data()
            let contentString = String(data: content, encoding: .ascii) ?? ""
            guard let decoded = Bencode(bencodedString: contentString) else { return nil }
            guard let info = decoded["info"].dict else { return nil }
            return info.first(where: { $0.key.key == "name" })?.value.string
        }
    }
    
    var url: URL {
        switch self {
        case .url(let url), .base64(let url, _):
            return url
        }
    }
}
