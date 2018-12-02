//
//  SYError.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Alamofire

enum SYError {
    case noMirrorsFound
    case noMagnetFound
    case noComputersSaved
    case alamofire(_ request: AlamoDataResponseProtocol)
}

extension SYError : LocalizedError {
    var localizedDescription: String {
        switch self {
        case .noMirrorsFound:
            return "No mirrors found"
        case .noMagnetFound:
            return "No magnet found"
        case .noComputersSaved:
            return "No computer saved in your settings, please add one before trying to download this item"
        case .alamofire(let response):
            return response.error?.localizedDescription ?? "Unknown error"
        }
    }
}

// MARK: Alamofire reponse handling
protocol AlamoDataResponseProtocol {
    var error: Error? { get }
    var response: HTTPURLResponse? { get }
}

extension DataResponse : AlamoDataResponseProtocol { }

extension AlamoDataResponseProtocol {
    var isUnreachable: Bool {
        return
            response?.statusCode == 500 ||
                response?.statusCode == 502 ||
                error?.isNSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut) == true
    }
    
    var isNotFoundError: Bool {
        return response?.statusCode == 404
    }

}

