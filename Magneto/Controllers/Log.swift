//
//  Log.swift
//  Magneto
//
//  Created by syan on 06/03/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation
import os

class Log {
    enum Tag: String {
        case searchAPI = "SearchAPI"
        case preferences = "Preferences"
        case update = "Update"

        var asOSLog: OSLog {
            return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: rawValue)
        }
    }
    
    private static func log(level: OSLogType, tag: Tag, _ message: String) {
        os_log(level, log: tag.asOSLog, "%@", message)
    }
    
    static func i(_ tag: Tag, _ message: String) {
        log(level: .info, tag: tag, message)
    }
    
    static func w(_ tag: Tag, _ message: String) {
        log(level: .debug, tag: tag, message)
    }

    static func e(_ tag: Tag, _ message: String) {
        log(level: .error, tag: tag, message)
    }
}


