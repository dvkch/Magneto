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

extension Notification.Name {
    static let mirrorsChanged = Notification.Name("WebAPI.mirrorsChanged")
}

class WebAPI: NSObject {
    
    // MARK: Init
    static let shared = WebAPI()
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 20
        // ignore cache for update management
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = Alamofire.Session(configuration: configuration)
        
        super.init()
        availableMirrorURLs = Preferences.shared.savedAvailableMirrors
    }
    
    // MARK: Properties
    private var session: Session
    private(set) var availableMirrorURLs = [URL]() {
        didSet {
            Preferences.shared.savedAvailableMirrors = availableMirrorURLs
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .mirrorsChanged, object: nil)
            }
            print("Using \(availableMirrorURLs.count) mirrors")
        }
    }
    
    // MARK: Update
    func getLatestBuildNumber() -> Future<Int?, AppError> {
        return session
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
        // Mirrors now seem to use the same API server, seen in /static/main-new.js. Instead of downloading that file and parsing the server,
        // we're just gonna use it for a while it see if it works reliably
        self.availableMirrorURLs = [URL(string: "https://bayapi.lol/")!]
        return .init(value: self.availableMirrorURLs.first!)
        
        if let mirrorURL = availableMirrorURLs.first {
            return .init(value: mirrorURL)
        }
        
        return self.session
            .request("https://pirateproxy.wtf/")
            .validate()
            .responseFutureHTML()
            .flatMap { (document) -> Future<URL, AppError> in
                let elements = document.xpath("//table[@class='proxies']/tbody/tr//a")
                let URLs = elements
                    .compactMap { $0.text }
                    .compactMap { URL(string: "https://" + $0) }
                    .filter { !Preferences.shared.mirrorBlacklist.contains($0) }
                
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
        urlComponents.path = "/q.php"
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "cat", value: "")
        ]
        return urlComponents.url!
    }
    
    func getResults(query: String) -> Future<[SearchResult], AppError> {
        return getMirror()
            .map { mirror in self.getQueryURL(mirrorURL: mirror, query: query) }
            .flatMap { url in return self.session.request(url).validate().responseFutureCodable(type: [SearchResult].self) }
            .map { $0.filter { $0.size > 0 } } // a single item with all attributes set to 0 is returned when no results have been found, let's handle this properly
            .recoverWith { (error) -> Future<[SearchResult], AppError> in
                if case let .alamofire(request) = error {
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
            .map { mirror in result.pageURL(mirror: mirror) }
    }
}
