//
//  Alamofire+SY.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 29/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Alamofire
import BrightFutures

extension URLRequest {
    var client: Client? {
        guard let requestURL = self.url else { return nil }
        for client in Preferences.shared.clients {
            if requestURL.absoluteString.hasPrefix(client.apiURL.absoluteString) {
                return client
            }
            if requestURL.absoluteString.hasPrefix(client.webURL.absoluteString) {
                return client
            }
        }
        return nil
    }
}

extension DataRequest {
    @discardableResult
    func responseCodable<T: Decodable>(queue: DispatchQueue = .main, type: T.Type, completionHandler: @escaping (DataResponse<T, Error>) -> Void) -> Self {
        return responseData(queue: queue) { (responseData) in
            let responseCodable = responseData.tryMap {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(.isoFormatter)

                return try decoder.decode(T.self, from: $0)
            }
            completionHandler(responseCodable)
        }
    }
}

extension DataRequest {
    func responseFutureData(queue: DispatchQueue = .main) -> Future<Data, AppError> {
        return Future<Data, AppError> { resolver in
            self.responseData(queue: queue, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(AppError.alamofire(response)))
                }
            })
        }
    }
    
    func responseFutureCodable<T: Decodable>(queue: DispatchQueue = .main, type: T.Type) -> Future<T, AppError> {
        return Future<T, AppError> { resolver in
            self.responseCodable(queue: queue, type: T.self, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(AppError.alamofire(response)))
                }
            })
        }
    }
}

