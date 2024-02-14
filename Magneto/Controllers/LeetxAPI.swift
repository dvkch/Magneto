//
//  LeetxAPI.swift
//  Magneto
//
//  Created by syan on 22/06/2023.
//  Copyright © 2023 Syan. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures

final class LeetxAPI: NSObject, SearchAPI {
    
    // MARK: Init
    static let shared = LeetxAPI()
    
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
    let apiURL = URL(string: "https://www.1337x.to")!
    
    // MARK: Methods
    func getResults(query: String) -> Future<[SearchResultLeetx], AppError> {
        let url = apiURL
            .appendingPathComponent("search")
            .appendingPathComponent(query.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+"))
            .appendingPathComponent("1")

        return session.request("https://hapier.syan.me/api/scrappers/1337x_results", parameters: ["url": url.absoluteString])
            .validate()
            .responseFutureCodable(type: [SearchResultLeetx].self)
            .recoverWith { (error) -> Future<[SearchResultLeetx], AppError> in
                if case let .alamofire(request) = error, request.isUnreachable {
                    return .init(error: .noAvailableAPI)
                }
                return .init(error: error)
            }
    }
    
    private struct ResultPage: Codable {
        let url: URL
    }
    func getMagnet(pageURL: URL) -> Future<URL, AppError> {
        return session.request("https://hapier.syan.me/api/scrappers/1337x_magnet", parameters: ["url": pageURL.absoluteString])
            .validate()
            .responseFutureCodable(type: ResultPage.self)
            .map { $0.url }
    }
}
