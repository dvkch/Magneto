//
//  AppError.swift
//  Magneto
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit
import Alamofire

enum AppError {
    case request(_ response: AlamofireDataResponse)
    case decoding(_ kind: String, _ error: Error?, _ message: String?)
    case cancelled
    case offline
    case noClientsSaved
    case noAvailableAPI
    case clientOffline
    #if DEBUG
    case notImplemented
    #endif
}

extension AppError : LocalizedError {
    var errorDescription: String? {
        if isOfflineError {
            return "error.offline".localized
        }
        
        switch self {
        case .request(let r):
            if let apiError {
                return [apiError.message, apiError.details].compactMap { $0 }.joined(separator: ": ")
            }
            return r.error?.localizedDescription ?? "error.request".localized
        case .decoding(let k, let e, let m):return "error.decoding".localized(k, e?.localizedDescription ?? m ?? "")
        case .cancelled:                    return "error.cancelled".localized
        case .offline:                      return "error.offline".localized
        case .noClientsSaved:               return "error.noClientsSaved".localized
        case .noAvailableAPI:               return "error.noAvailableAPI".localized
        case .clientOffline:                return "error.clientOffline".localized
#if DEBUG
        case .notImplemented:               return "NOT IMPLEMENTED"
#endif
        }
    }
    
    var apiError: ApiError? {
        guard case let .request(response) = self else { return nil }
        return try? JSONDecoder().decode(ApiError.self, from: response.data)
    }
    
    var underlyingError: Error? {
        switch self {
        case .request(let r):               return r.error?.underlyingError ?? r.error
        case .decoding(_, let e, _):        return e
        case .cancelled:                    return nil
        case .offline:                      return nil
        case .noClientsSaved:               return nil
        case .noAvailableAPI:               return nil
        case .clientOffline:                return nil
#if DEBUG
        case .notImplemented:               return nil
#endif
        }
    }
    
    var isOfflineError: Bool {
        if case .offline = self {
            return true
        }
        
        guard var error = underlyingError else { return false }
        if error.isOfflineError {
            return true
        }
        
        while error.underlyingErrors.isNotEmpty {
            error = error.underlyingErrors[0]
            if error.isOfflineError {
                return true
            }
        }
        return false
    }
}

extension Error {
    fileprivate var underlyingErrors: [Error] {
        var errors = [Error]()
        if let e = (self as NSError).userInfo[NSUnderlyingErrorKey] as? NSError {
            errors.append(e)
        }
        if #available(iOS 14.5, *) {
            errors += (self as NSError).userInfo[NSMultipleUnderlyingErrorsKey] as? [NSError] ?? []
        }
        return errors
    }
}
