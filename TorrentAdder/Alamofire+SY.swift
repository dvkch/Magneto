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
    var computer: SYClient? {
        guard let requestURL = self.url else { return nil }
        for computer in SYPreferences.shared.computers {
            if requestURL.absoluteString.hasPrefix(computer.apiURL.absoluteString) {
                return computer
            }
            if requestURL.absoluteString.hasPrefix(computer.webURL.absoluteString) {
                return computer
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
    
    func responseFutureData(queue: DispatchQueue? = .main) -> Future<Data, SYError> {
        return Future<Data, SYError> { resolver in
            self.responseData(queue: queue, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(SYError.alamofire(response)))
                }
            })
        }
    }
    
    func responseFutureJSON(queue: DispatchQueue? = .main) -> Future<Any, SYError> {
        return Future<Any, SYError> { resolver in
            self.responseJSON(queue: queue, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(SYError.alamofire(response)))
                }
            })
        }
    }
    
    func responseFutureCodable<T: Decodable>(queue: DispatchQueue? = .main, type: T.Type) -> Future<T, SYError> {
        return Future<T, SYError> { resolver in
            self.responseCodable(queue: queue, type: T.self, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(SYError.alamofire(response)))
                }
            })
        }
    }
    
    func responseFutureXML(queue: DispatchQueue? = .main) -> Future<XMLDocument, SYError> {
        return Future<XMLDocument, SYError> { resolver in
            self.responseXML(queue: queue, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(SYError.alamofire(response)))
                }
            })
        }
    }
    
    func responseFutureHTML(queue: DispatchQueue? = .main) -> Future<HTMLDocument, SYError> {
        return Future<HTMLDocument, SYError> { resolver in
            self.responseHTML(queue: queue, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(SYError.alamofire(response)))
                }
            })
        }
    }

    func responseFutureHTML(queue: DispatchQueue? = .main, XPathQuery: String) -> Future<NodeSet, SYError> {
        return Future<NodeSet, SYError> { resolver in
            self.responseHTML(queue: queue, XPathQuery: XPathQuery, completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver(.success(value))
                case .failure:
                    resolver(.failure(SYError.alamofire(response)))
                }
            })
        }
    }
}

