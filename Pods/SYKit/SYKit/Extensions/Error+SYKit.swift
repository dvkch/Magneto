//
//  Error+SYKit.swift
//  SYKit
//
//  Created by Stanislas Chevallier on 29/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

public extension Error {
    func isNSError(domain: String, code: Int) -> Bool {
        return (self as NSError).domain == domain && (self as NSError).code == code
    }
    
    func isNSError(domain: String, codes: [Int]) -> Bool {
        return (self as NSError).domain == domain && codes.contains((self as NSError).code)
    }
    
    var isOfflineError: Bool {
        let offlineCodes = [NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet]
        return self.isNSError(domain: NSURLErrorDomain, codes: offlineCodes)
    }
}
