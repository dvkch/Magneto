//
//  AppError.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Alamofire

enum AppError {
    case noMagnetFound
    case noClientsSaved
    case noUTorrentToken
    case invalidUTorrentPayload
    case noAvailableAPI
    case clientOffline
    case alamofire(_ request: AlamoDataResponseProtocol)
}

extension AppError : LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noMagnetFound:                return "error.noMagnetFound".localized
        case .noClientsSaved:               return "error.noClientsSaved".localized
        case .noUTorrentToken:              return "error.noUTorrentToken".localized
        case .invalidUTorrentPayload:       return "error.invalidUTorrentPayload".localized
        case .noAvailableAPI:               return "error.noAvailableAPI".localized
        case .clientOffline:                return "error.clientOffline".localized
        case .alamofire(let response):
            var message = response.untypedError?.localizedDescription ?? "error.unknown".localized
            if let statusCode = response.response?.statusCode {
                message += " (\(statusCode)"
            }
            return message
        }
    }
}

// MARK: Alamofire reponse handling
protocol AlamoDataResponseProtocol {
    var untypedError: Error? { get }
    var response: HTTPURLResponse? { get }
    var data: Data? { get }
}

extension DataResponse : AlamoDataResponseProtocol {
    var untypedError: Error? {
        error
    }
}

extension AlamoDataResponseProtocol {
    var isUnreachable: Bool {
        if (response?.statusCode ?? 0) >= 500 {
            return true
        }
        if (untypedError as? AFError)?.underlyingError?.isNSError(domain: NSURLErrorDomain, codes: [NSURLErrorTimedOut, NSURLErrorCannotFindHost]) == true {
            return true
        }
        return false
    }
    
    var isNotFoundError: Bool {
        return response?.statusCode == 404
    }
}

