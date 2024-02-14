//
//  YtsAPI.swift
//  Magneto
//
//  Created by syan on 13/02/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import Alamofire
import BrightFutures

final class YtsAPI: NSObject, SearchAPI {
    
    // MARK: Init
    static let shared = YtsAPI()
    
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
    let apiURL = URL(string: "https://yts.mx")!
    
    // MARK: Methods
    func getResults(query: String) -> Future<[SearchResultYts], AppError> {
        let url = apiURL
            .appendingPathComponent("browse-movies")
            .appendingPathComponent(query.trimmingCharacters(in: .whitespacesAndNewlines))

        return session.request("https://hapier.syan.me/api/scrappers/yts_results", parameters: ["url": url.absoluteString])
            .validate()
            .responseFutureCodable(type: [SearchResultYts].self)
            .recoverWith { (error) -> Future<[SearchResultYts], AppError> in
                if case let .alamofire(request) = error, request.isUnreachable {
                    return .init(error: .noAvailableAPI)
                }
                return .init(error: error)
            }
    }
    
    private var variantsCache: [URL: [SearchResultVariantYts]] = [:]
    
    func variants(for result: SearchResultYts) -> [SearchResultVariantYts]? {
        return variantsCache[result.resultPageURL]
    }

    func loadVariants(result: SearchResultYts) -> Future<(), AppError> {
        if variantsCache.keys.contains(result.resultPageURL) {
            return .init(value: ())
        }

        return session.request("https://hapier.syan.me/api/scrappers/yts_variants", parameters: ["url": result.resultPageURL.absoluteString])
            .validate()
            .responseFutureCodable(type: [SearchResultVariantYts].self)
            .onSuccess { self.variantsCache[result.resultPageURL] = $0 }
            .map { _ in () }
    }
}
