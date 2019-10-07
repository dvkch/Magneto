//
//  Alamofire+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 29/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import Alamofire
import Fuzi
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
    func responseCodable<T: Decodable>(queue: DispatchQueue? = .main, type: T.Type, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return responseData(queue: queue) { (responseData) in
            let responseCodable = responseData.flatMap { try JSONDecoder().decode(T.self, from: $0) }
            completionHandler(responseCodable)
        }
    }
    
    @discardableResult
    func responseXML(queue: DispatchQueue? = .main, completionHandler: @escaping (DataResponse<XMLDocument>) -> Void) -> Self {
        return responseData(queue: queue) { (responseData) in
            let responseXML = responseData.flatMap { try XMLDocument(data: $0) }
            completionHandler(responseXML)
        }
    }

    @discardableResult
    func responseHTML(queue: DispatchQueue? = .main, completionHandler: @escaping (DataResponse<HTMLDocument>) -> Void) -> Self {
        return responseData(queue: queue) { (responseData) in
            let responseHTML = responseData.flatMap { try HTMLDocument(data: $0) }
            completionHandler(responseHTML)
        }
    }

    @discardableResult
    func responseHTML(queue: DispatchQueue? = .main, XPathQuery: String, completionHandler: @escaping (DataResponse<NodeSet>) -> Void) -> Self {
        return responseData(queue: queue) { (responseData) in
            let responseHTML = responseData.flatMap { try HTMLDocument(data: $0).xpath(XPathQuery) }
            completionHandler(responseHTML)
        }
    }
}

extension DataRequest {
    
    func responseFutureData(queue: DispatchQueue? = .main) -> Future<Data, AppError> {
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
    
    func responseFutureJSON(queue: DispatchQueue? = .main) -> Future<Any, AppError> {
        return Future<Any, AppError> { resolver in
            self.responseJSON(queue: queue, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(AppError.alamofire(response)))
                }
            })
        }
    }
    
    func responseFutureCodable<T: Decodable>(queue: DispatchQueue? = .main, type: T.Type) -> Future<T, AppError> {
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
    
    func responseFutureXML(queue: DispatchQueue? = .main) -> Future<XMLDocument, AppError> {
        return Future<XMLDocument, AppError> { resolver in
            self.responseXML(queue: queue, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(AppError.alamofire(response)))
                }
            })
        }
    }
    
    func responseFutureHTML(queue: DispatchQueue? = .main) -> Future<HTMLDocument, AppError> {
        return Future<HTMLDocument, AppError> { resolver in
            self.responseHTML(queue: queue, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(AppError.alamofire(response)))
                }
            })
        }
    }

    func responseFutureHTML(queue: DispatchQueue? = .main, XPathQuery: String) -> Future<NodeSet, AppError> {
        return Future<NodeSet, AppError> { resolver in
            self.responseHTML(queue: queue, XPathQuery: XPathQuery, completionHandler: { (response) in
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

