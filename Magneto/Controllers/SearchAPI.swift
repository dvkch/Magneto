//
//  SearchAPI.swift
//  Magneto
//
//  Created by syan on 15/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures

class SearchAPI {
    
    static let shared = SearchAPI()
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 20
        // ignore cache for update management
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        session = Alamofire.Session(configuration: configuration)
    }
    
    // MARK: Properties
    private var session: Session

    // MARK: Generic
    private func scrap<T: Decodable>(_ url: URL, using scrapper: String, into type: T.Type) -> Future<T, AppError> {
        return session.request("https://hapier.syan.me/api/scrappers/\(scrapper)", parameters: ["url": url.absoluteString])
            .validate()
            .responseFutureCodable(type: T.self)
            .recoverWith { (error) -> Future<T, AppError> in
                if case let .alamofire(request) = error, request.isUnreachable {
                    return .init(error: .noAvailableAPI)
                }
                print(error)
                return .init(error: error)
            }
    }
    
    // MARK: Mirror types
    private struct Mirror: Codable {
        let url: URL
    }
    private struct ValidationResponse: Codable {
        let value: String
    }
    struct MirrorConfig {
        let listURL: URL
        let listScrapper: String
        let validatorScrapper: String
        let expectedValue: String
    }
    
    // MARK: Mirrors
    private var mirrorURLs = [URL: [URL]]()

    private func getWebMirrorURLs(config: MirrorConfig) -> Future<[URL], AppError> {
        return scrap(config.listURL, using: config.listScrapper, into: [Mirror].self)
            .map { $0.map(\.url) }
            .onSuccess { self.mirrorURLs[config.listURL] = $0 }
    }
    
    private func isMirrorReachable(_ url: URL, config: MirrorConfig) -> Future<URL, AppError> {
        return scrap(url, using: config.validatorScrapper, into: ValidationResponse.self)
            .flatMap {
                if $0.value.contains(config.expectedValue) {
                    return .init(value: url)
                }
                return .init(error: .noAvailableAPI)
            }
    }
    
    func getWebMirrorURL(config: MirrorConfig, allowRetry: Bool = true) -> Future<URL, AppError> {
        guard let firstMirror = mirrorURLs[config.listURL]?.first else {
            guard allowRetry else {
                return .init(error: .noAvailableAPI)
            }
                
            return getWebMirrorURLs(config: config).flatMap { _ in
                self.getWebMirrorURL(config: config, allowRetry: false)
            }
        }
        
        return isMirrorReachable(firstMirror, config: config)
            .recoverWith { _ in
                self.mirrorURLs[config.listURL]?.remove(firstMirror)
                return self.getWebMirrorURL(config: config, allowRetry: allowRetry)
            }
    }
    
    // MARK: Results
    func getResults<T: SearchResult>(config: MirrorConfig, query: String, queryTemplate: [String?], scrapper: String, type: T.Type) -> Future<[T], AppError> {
        return getWebMirrorURL(config: config)
            .flatMap { self.getResults(mirror: $0, query: query, queryTemplate: queryTemplate, scrapper: scrapper, type: type) }
    }
    
    func getResults<T: SearchResult>(mirror: URL, query: String, queryTemplate: [String?], scrapper: String, type: T.Type) -> Future<[T], AppError> {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var url = mirror
        queryTemplate.forEach { part in
            url = url.appendingPathComponent(part ?? q)
        }
        
        return scrap(url, using: scrapper, into: [T].self)
    }
    
    // MARK: Magnets
    private struct ResultPage: Codable {
        let url: URL
    }

    func getMagnet(for url: URL, scrapper: String) -> Future<URL, AppError> {
        return scrap(url, using: scrapper, into: ResultPage.self)
            .map { $0.url }
    }

    // MARK: Variants
    private var variantsCache: [URL: [any SearchResultVariant]] = [:]

    func cachedVariants<T: SearchResultVariant>(for url: URL, type: T.Type) -> [T]? {
        return variantsCache[url] as? [T]
    }

    func loadVariants<T: SearchResultVariant>(for url: URL, scrapper: String, type: T.Type) -> Future<(), AppError> {
        if variantsCache.keys.contains(url) {
            return .init(value: ())
        }

        return scrap(url, using: scrapper, into: [T].self)
            .onSuccess { self.variantsCache[url] = $0 }
            .map { _ in () }
    }
}

