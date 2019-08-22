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
    case noClientsSaved
    case noUTorrentToken
    case invalidUTorrentPayload
    case noMirrorAnswered
    case clientOffline
    case alamofire(_ request: AlamoDataResponseProtocol)
}

extension SYError : LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noMirrorsFound:               return "error.noMirrorsFound".localized
        case .noMagnetFound:                return "error.noMagnetFound".localized
        case .noClientsSaved:               return "error.noClientsSaved".localized
        case .noUTorrentToken:              return "error.noUTorrentToken".localized
        case .invalidUTorrentPayload:       return "error.invalidUTorrentPayload".localized
        case .noMirrorAnswered:             return "error.noMirrorAnswered".localized
        case .clientOffline:                return "error.clientOffline".localized
        case .alamofire(let response):      return response.error?.localizedDescription ?? "error.unknown".localized
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
        if (response?.statusCode ?? 0) >= 500 {
            return true
        }
        if error?.isNSError(domain: NSURLErrorDomain, codes: [NSURLErrorTimedOut, NSURLErrorCannotFindHost]) == true {
            return true
        }
        return false
    }
    
    var isNotFoundError: Bool {
        return response?.statusCode == 404
    }
}

