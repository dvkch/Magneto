//
//  T9API.swift
//  Magneto
//
//  Created by syan on 24/01/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures

final class T9API: NSObject, SearchAPI {
    
    // MARK: Init
    static let shared = T9API()
    
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
    let apiURL = URL(string: "https://www.torrent9.boo")!
    
    // MARK: Methods
    func getResults(query: String) -> Future<[SearchResultT9], AppError> {
        let url = apiURL
            .appendingPathComponent("recherche")
            .appendingPathComponent(query.trimmingCharacters(in: .whitespacesAndNewlines))

        return session.request("https://hapier.syan.me/api/scrappers/t9_results", parameters: ["url": url.absoluteString])
            .validate()
            .responseFutureCodable(type: [SearchResultT9].self)
            .recoverWith { (error) -> Future<[SearchResultT9], AppError> in
                if case let .alamofire(request) = error, request.isUnreachable {
                    return .init(error: .noAvailableAPI)
                }
                return .init(error: error)
            }
    }
    
    private struct ResultPage: Codable {
        let url: URL
    }
    func getMagnet(result: SearchResultT9) -> Future<URL, AppError> {
        return session.request("https://hapier.syan.me/api/scrappers/t9_magnet", parameters: ["url": result.resultPageURL.absoluteString])
            .validate()
            .responseFutureCodable(type: ResultPage.self)
            .map { $0.url }
    }
}
