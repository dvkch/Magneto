//
//  SearchResultTpb.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import BrightFutures

struct SearchResultTpb : SearchResult {

    // MARK: Properties
    let id: String
    let name: String
    let infoHash: String
    let seeders: Int
    let leechers: Int
    let sizeInt: Int64
    let size: String
    let verified: Bool
    let added: Date

    // MARK: Decodable
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case infoHash = "info_hash"
        case seeders = "seeders"
        case leechers = "leechers"
        case size = "size"
        case status = "status"
        case added = "added"
    }
    
    private static let sizeFormatter = {
        let bf = ByteCountFormatter()
        bf.allowedUnits = [.useAll]
        bf.countStyle = .file
        return bf
    }()

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        infoHash = try container.decode(String.self, forKey: .infoHash)
        seeders = (try container.decode(IntMaybeString.self, forKey: .seeders)).value
        leechers = (try container.decode(IntMaybeString.self, forKey: .leechers)).value
        sizeInt = Int64(try container.decode(String.self, forKey: .size)) ?? 0
        size = SearchResultTpb.sizeFormatter.string(fromByteCount: sizeInt)
        verified = (try container.decode(String.self, forKey: .status)) == "trusted"
        added = Date(timeIntervalSince1970: TimeInterval(Int((try container.decode(String.self, forKey: .added))) ?? 0))
    }

    // MARK: URLs
    let pageURLAvailable: Bool = false

    func pageURL() -> Future<URL, AppError> {
        return TpbAPI.shared.getWebMirrorURL().map { mirrorURL in
            var components = URLComponents(url: mirrorURL, resolvingAgainstBaseURL: true)!
            components.path = "/description.php"
            components.queryItems = [URLQueryItem(name: "id", value: id)]
            return components.url!
        }
    }

    func magnetURL() -> Future<URL, AppError> {
        var components = URLComponents()
        components.scheme = "magnet"
        components.queryItems = [
            URLQueryItem(name: "xt", value: "urn:btih:" + infoHash),
            URLQueryItem(name: "dn", value: name),
            URLQueryItem(name: "tr", value: "udp://tracker.coppersurfer.tk:6969/announce"),
            URLQueryItem(name: "tr", value: "udp://9.rarbg.to:2920/announce"),
            URLQueryItem(name: "tr", value: "udp://tracker.opentrackr.org:1337"),
            URLQueryItem(name: "tr", value: "udp://tracker.internetwarriors.net:1337/announce"),
            URLQueryItem(name: "tr", value: "udp://tracker.leechers-paradise.org:6969/announce"),
            URLQueryItem(name: "tr", value: "udp://tracker.coppersurfer.tk:6969/announce"),
            URLQueryItem(name: "tr", value: "udp://tracker.pirateparty.gr:6969/announce"),
            URLQueryItem(name: "tr", value: "udp://tracker.cyberia.is:6969/announce"),
        ]

        return .init(value: components.url!)
    }
}
