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

extension DataRequest {
    
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

