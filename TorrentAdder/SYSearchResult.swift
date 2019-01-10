//
//  SYSearchResult.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Fuzi

struct SYSearchResult {

    // MARK: Properties
    let name: String
    let size: String?
    let age: String?
    let parsedDate: Date?
    let verified: Bool
    let seed: Int
    let leech: Int
    let pagePath: String
    var magnetURL: URL?

}

extension SYSearchResult : CustomStringConvertible {
    var description: String {
        return "Result: \(name), \(size ?? ""), \(age ?? ""), \(seed)/\(leech), vip=\(verified)"
    }
}

// MARK: Parsing
extension SYSearchResult {
    
    static func parseModels(html: HTMLDocument) -> [SYSearchResult] {
        var elements = html.xpath("//table[@id='searchResult']/tr")
        if elements.isEmpty {
            elements = html.xpath("//table[@id='searchResult']/tbody/tr")
        }
        return elements.compactMap { parseModel(html: $0) }
    }
    
    private static func parseModel(html: XMLElement) -> SYSearchResult? {
        let tds = html.children(tag: "td")
        let tdDetails = tds.element(at: 1)
        let seed      = tds.element(at: 2)?.text.map { Int($0) } ?? 0
        let leech     = tds.element(at: 3)?.text.map { Int($0) } ?? 0
        
        let name1 = tdDetails?.firstChild(tag: "div")?.firstChild(tag: "a")?.text
        let name2 = tdDetails?.firstChild(tag: "div")?.firstChild(tag: "a")?.firstChild(tag: "span")?.text
        guard let name = name1 ?? name2 else { return nil }

        let pagePath = tdDetails?.firstChild(tag: "div")?.firstChild(tag: "a")?.attr("href") ?? ""
        guard !pagePath.isEmpty else { return nil }
        
        let fontChild = tdDetails?.firstChild(tag: "font")
        var dateSizeAndUser = fontChild?.text ?? ""
        if let b = fontChild?.firstChild(tag: "b")?.text {
            dateSizeAndUser += b
        }
        
        if let a = fontChild?.firstChild(tag: "a")?.text {
            dateSizeAndUser += a
        }
        else if let i = fontChild?.firstChild(tag: "i")?.text {
            dateSizeAndUser += i
        }
        
        let components = dateSizeAndUser.components(separatedBy: ", ")
        let age = components.first?.replacingOccurrences(of: "Uploaded ", with: "")
        let size = components.element(at: 1)?.replacingOccurrences(of: "Size ", with: "")
        
        let verified = tdDetails?.rawXML.contains("VIP") ?? false
        
        return SYSearchResult(
            name: name,
            size: size,
            age: age,
            parsedDate: parseDate(age: age),
            verified: verified,
            seed: seed ?? 0,
            leech: leech ?? 0,
            pagePath: pagePath,
            magnetURL: nil
        )
    }
    
    static func parseDate(age: String?) -> Date? {
        guard let age = age, !age.isEmpty else { return nil }
        
        if age.hasPrefix("Today") {
            let formatter = DateFormatter()
            formatter.dateFormat = "'Today 'HH:mm"
            
            let cal = Calendar(identifier: .gregorian)
            let time = formatter.date(from: age)
            return cal.dateCombining(day: Date(), time: time)
        }
        else if age.hasPrefix("Y-day") {
            let formatter = DateFormatter()
            formatter.dateFormat = "'Y-day 'HH:mm"
            
            let cal = Calendar(identifier: .gregorian)
            let yDay = cal.date(byAdding: Calendar.Component.day, value: -1, to: Date())
            let time = formatter.date(from: age)
            return cal.dateCombining(day: yDay, time: time)
        }
        else if age.contains(":") {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd' 'HH:mm"
            
            let cal = Calendar(identifier: .gregorian)
            let dayAndTime = formatter.date(from: age)
            return cal.dateCombining(year: Date(), dayAndTime: dayAndTime)
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd' 'yyyy"
            return formatter.date(from: age)
        }
    }
    
    static func parseMagnetURL(html: HTMLDocument) -> URL? {
        let links = html.xpath("//div[@class='download']/a")
        let URLs = links
            .compactMap { $0.attr("href") }
            .filter { $0.hasPrefix("magnet:") }
            .compactMap { URL(string: $0) }
        
        return URLs.first
    }
}
