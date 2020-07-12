//
//  SearchResult.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Fuzi

struct SearchResult {

    // MARK: Properties
    let name: String
    let size: String?
    let date: Date?
    let verified: Bool
    let seed: Int
    let leech: Int
    let pageURL: URL
    var magnetURL: URL?
}

extension SearchResult : CustomStringConvertible {
    var description: String {
        return "Result: \(name), \(size ?? ""), \(date?.description ?? ""), \(seed)/\(leech), vip=\(verified)"
    }
}

// MARK: Parsing
extension SearchResult {
    
    static func parseModels(html: HTMLDocument) -> [SearchResult] {
        let elements = html.css("ol#torrents li.list-entry")
        return elements.compactMap { parseModel(html: $0) }
    }
    
    private static func parseModel(html: XMLElement) -> SearchResult? {
        guard let name = html.firstChild(css: "span.item-title a")?.text else { return nil }
        guard let url = html.firstChild(css: "span.item-title a")?.attr("href")?.url else { return nil }

        let seed        = html.firstChild(css: "span.item-seed")?.text.map { Int($0) } ?? 0
        let leech       = html.firstChild(css: "span.item-leech")?.text.map { Int($0) } ?? 0
        let size        = html.firstChild(css: "span.item-size")?.text
        let date        = html.firstChild(css: "span.item-uploaded")?.text.map { parseDate($0) } ?? nil
        let verified    = html.css("span.item-icons img").contains(where: { $0.attr("alt") == "Trusted" })
        let magnet      = html.firstChild(css: "span.item-icons a.js-magnet-link")?.attr("href")?.magnetURL
        
        return SearchResult(
            name: name,
            size: size,
            date: date,
            verified: verified,
            seed: seed ?? 0,
            leech: leech ?? 0,
            pageURL: url,
            magnetURL: magnet
        )
    }
    
    static func parseDate(_ string: String?) -> Date? {
        guard let string = string, !string.isEmpty else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
    
    static func parseMagnetURL(html: HTMLDocument) -> URL? {
        let links = html.css("div.links a.js-magnet-link")
        let URLs = links
            .compactMap { $0.attr("href") }
            .filter { $0.hasPrefix("magnet:") }
            .compactMap { $0.magnetURL }
        
        return URLs.first
    }
}
