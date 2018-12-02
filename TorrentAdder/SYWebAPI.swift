//
//  SYWebAPI.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 29/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Alamofire
import Fuzi
import BrightFutures

class SYWebAPI: NSObject {
    
    // MARK: Init
    static let shared = SYWebAPI()
    
    override init() {
        super.init()
        availableMirrorURLs = SYPreferences.shared.savedAvailableMirrors
    }
    
    // MARK: Properties
    private var availableMirrorURLs = [URL]() {
        didSet {
            SYPreferences.shared.savedAvailableMirrors = availableMirrorURLs
            print("Using \(availableMirrorURLs.count) mirrors")
        }
    }
    private var magnetCache: [String: URL] = [:]
    
    // MARK: Methods
    private func getMirror() -> Future<URL, SYError> {
        if let mirrorURL = availableMirrorURLs.first {
            return .init(value: mirrorURL)
        }
        
        return Alamofire
            .request("https://thepiratebay-proxylist.se/")
            .responseFutureHTML(XPathQuery: "//td[@title='URL']")
            .flatMap { (elements) -> BrightResult<URL, SYError> in
                let URLs = elements
                    .compactMap { $0.attr("data-href") }
                    .compactMap { URL(string: $0) }
                
                if let mirrorURL = URLs.first {
                    self.availableMirrorURLs = URLs
                    return .init(value: mirrorURL)
                }
                else {
                    return .init(error: SYError.noMirrorsFound)
                }
            }
    }
    
    private func getQueryURL(mirrorURL: URL, query: String) -> URL {
        var urlComponents = URLComponents(url: mirrorURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = "/s"
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(0)),
            URLQueryItem(name: "orderby", value: String(99))
        ]
        return try! urlComponents.asURL()
    }
    
    func getResults(query: String) -> Future<[SYSearchResult], SYError> {
        return getMirror()
            .map { mirror in self.getQueryURL(mirrorURL: mirror, query: query) }
            .flatMap { url in Alamofire.request(url).responseFutureHTML() }
            .map { html in SYSearchResult.parseModels(html: html)  }
            .recoverWith { (error) -> Future<[SYSearchResult], SYError> in
                if case let .alamofire(request) = error {
                    if request.isNotFoundError {
                        return .init(value: [])
                    }
                    if request.isUnreachable && self.availableMirrorURLs.count > 1 {
                        self.availableMirrorURLs.removeFirst()
                        return self.getResults(query: query)
                    }
                }
                return .init(error: error)
            }
    }
    
    func getResultPageURL(_ result: SYSearchResult) -> Future<URL, SYError> {
        return getMirror()
            .map { $0.appendingPathComponent(result.pagePath) }
    }
    
    func getMagnet(for result: SYSearchResult) -> Future<URL, SYError> {
        if let url = magnetCache[result.pagePath] {
            return .init(value: url)
        }

        return getResultPageURL(result)
            .flatMap { url in Alamofire.request(url).responseFutureHTML() }
            .flatMap { (html) -> BrightResult<URL, SYError> in
                if let url = SYSearchResult.parseMagnetURL(html: html) {
                    self.magnetCache[result.pagePath] = url
                    return .init(value: url)
                }
                return .init(error: SYError.noMagnetFound)
        }
    }
}
