//
//  WebAPI.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 29/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Alamofire
import Fuzi
import BrightFutures

class WebAPI: NSObject {
    
    // MARK: Init
    static let shared = WebAPI()
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 20
        // ignore cache for update management
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        manager = Alamofire.SessionManager(configuration: configuration)
        
        super.init()
        availableMirrorURLs = Preferences.shared.savedAvailableMirrors
    }
    
    // MARK: Properties
    private var manager: SessionManager
    private var availableMirrorURLs = [URL]() {
        didSet {
            Preferences.shared.savedAvailableMirrors = availableMirrorURLs
            print("Using \(availableMirrorURLs.count) mirrors")
        }
    }
    private var magnetCache: [String: URL] = [:]
    
    // MARK: Update
    func getLatestBuildNumber() -> Future<Int?, AppError> {
        return manager
            .request("https://ota.syan.me/TorrentAdder.plist")
            .responseFutureData()
            .map { (data) -> Int? in
                guard let dic = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else { return nil }
                guard let buildNumberString = dic["CFBundleVersion"] as? String else { return nil }
                return Int(buildNumberString)
            }
    }
    
    // MARK: Methods
    func clearMirrors() {
        availableMirrorURLs = []
    }
    
    private func getMirror() -> Future<URL, AppError> {
        if let mirrorURL = availableMirrorURLs.first {
            return .init(value: mirrorURL)
        }
        
        return self.manager
            .request("https://thepiratebay-proxylist.se/")
            .validate()
            .responseFutureHTML()
            .flatMap { (document) -> Future<URL, AppError> in
                let elements = document.xpath("//td[@title='URL']")
                let URLs = elements
                    .compactMap { $0.attr("data-href") }
                    .compactMap { URL(string: $0) }
                
                if let mirrorURL = URLs.first {
                    self.availableMirrorURLs = URLs
                    return .init(value: mirrorURL)
                }
                else {
                    return .init(error: AppError.noMirrorsFound)
                }
            }
    }
    
    private func getQueryURL(mirrorURL: URL, query: String) -> URL {
        var urlComponents = URLComponents(url: mirrorURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = "/s/"
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(0)),
            URLQueryItem(name: "orderby", value: String(99))
        ]
        return try! urlComponents.asURL()
    }
    
    func getResults(query: String) -> Future<[SearchResult], AppError> {
        return getMirror()
            .map { mirror in self.getQueryURL(mirrorURL: mirror, query: query) }
            .flatMap { url in self.manager.request(url).validate().responseFutureHTML() }
            .map { html in SearchResult.parseModels(html: html)  }
            .recoverWith { (error) -> Future<[SearchResult], AppError> in
                if case let .alamofire(request) = error {
                    if request.isNotFoundError {
                        return .init(value: [])
                    }
                    if request.isUnreachable {
                        if self.availableMirrorURLs.count > 1 {
                            self.availableMirrorURLs.removeFirst()
                            return self.getResults(query: query)
                        }
                        else {
                            // report the error, but next time we will reload mirrors
                            self.availableMirrorURLs = []
                            return .init(error: .noMirrorAnswered)
                        }
                    }
                }
                return .init(error: error)
            }
    }
    
    func getResultPageURL(_ result: SearchResult) -> Future<URL, AppError> {
        return getMirror()
            .map { $0.appendingPathComponent(result.pagePath) }
    }
    
    func getMagnet(for result: SearchResult) -> Future<URL, AppError> {
        if let url = magnetCache[result.pagePath] {
            return .init(value: url)
        }

        return getResultPageURL(result)
            .flatMap { url in self.manager.request(url).validate().responseFutureHTML() }
            .flatMap { (html) -> Future<URL, AppError> in
                if let url = SearchResult.parseMagnetURL(html: html) {
                    self.magnetCache[result.pagePath] = url
                    return .init(value: url)
                }
                return .init(error: AppError.noMagnetFound)
        }
    }
}
