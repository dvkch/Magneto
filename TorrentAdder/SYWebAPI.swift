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
    
    // MARK: Methods
    private func getMirror() -> Future <URL, SYError> {
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
    
    func getResults(query: String) -> Future<[SYResultModel], SYError> {
        return getMirror()
            .map { mirror in self.getQueryURL(mirrorURL: mirror, query: query) }
            .flatMap { url in Alamofire.request(url).responseFutureHTML() }
            .map { html in
                // let results = SYResultModel.results(fromWebData: response.data!, rootURL: mirrorURL)
                return []
            }
            .recoverWith { (error) -> Future<[SYResultModel], SYError> in
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
    
    func getMagnet(for result: SYResultModel) -> Future<URL, SYError> {
        if let magnet = result.magnet {
            return .init(value: magnet)
        }

        return getMirror()
            .map { mirror in mirror.appendingPathComponent(result.pageURL) }
            .flatMap { url in Alamofire.request(url).responseFutureHTML() }
            .flatMap { (html) -> BrightResult<URL, SYError> in
                result.updateMagnetURL(fromWebData: Data())
                if let url = result.magnet {
                    return .init(value: url)
                }
                return .init(error: SYError.noMagnetFound)
        }
    }
}
