//
//  TpbAPI.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 29/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Alamofire
import BrightFutures

final class TpbAPI: NSObject, SearchAPI {
    
    // MARK: Init
    static let shared = TpbAPI()
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 20
        // ignore cache for update management
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = Alamofire.Session(configuration: configuration)
        
        super.init()
    }
    
    // MARK: Properties
    private var session: Session
    private let apiURL = URL(string: "https://bayapi.lol/")!
    
    // MARK: Web URL
    private struct Mirror: Codable {
        let url: String
    }
    private var webMirrorURLs: [URL] = []
    private func getWebMirrorURLs() -> Future<[URL], AppError> {
        return session.request("https://hapier.syan.me/api/scrappers/tpb_proxies", parameters: ["url": "https://pirateproxy.wtf/"])
            .validate()
            .responseFutureCodable(type: [Mirror].self)
            .map { $0.compactMap { URL(string: "https://" + $0.url) } }
            .onSuccess { self.webMirrorURLs = $0 }
    }
    
    private struct ValidationResponse: Codable {
        let title: String
    }
    private func isMirrorReachable(_ url: URL) -> Future<URL, AppError> {
        return session.request("https://hapier.syan.me/api/scrappers/tpb_validator", parameters: ["url": url.absoluteString])
            .validate()
            .responseFutureCodable(type: ValidationResponse.self)
            .flatMap {
                if $0.title.contains("The Pirate Bay") {
                    return .init(value: url)
                }
                return .init(error: .noAvailableAPI)
            }
    }

    func getWebMirrorURL(allowRetry: Bool = true) -> Future<URL, AppError> {
        guard let firstMirror = webMirrorURLs.first else {
            if allowRetry {
                return getWebMirrorURLs().flatMap { _ in
                    self.getWebMirrorURL(allowRetry: false)
                }
            }
            return .init(error: .noAvailableAPI)
        }

        return isMirrorReachable(firstMirror)
            .recoverWith { _ in
                self.webMirrorURLs.remove(firstMirror)
                return self.getWebMirrorURL(allowRetry: false)
            }
    }
    
    // MARK: Methods
    private func getQueryURL(query: String) -> URL {
        var urlComponents = URLComponents(url: apiURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = "/q.php"
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "cat", value: "")
        ]
        return urlComponents.url!
    }
    
    func getResults(query: String) -> Future<[SearchResultTpb], AppError> {
        let url = getQueryURL(query: query)
        return session.request(url).validate()
            .responseFutureCodable(type: [SearchResultTpb].self)
            // a single item with all attributes set to 0 is returned when no results have been found, let's handle this properly
            .map { $0.filter { $0.sizeInt > 0 } }
            .recoverWith { (error) -> Future<[SearchResultTpb], AppError> in
                if case let .alamofire(request) = error, request.isUnreachable {
                    return .init(error: .noAvailableAPI)
                }
                return .init(error: error)
            }
    }
}
