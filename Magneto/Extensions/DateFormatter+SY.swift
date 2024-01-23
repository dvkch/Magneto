//
//  DateFormatter+SY.swift
//  Magneto
//
//  Created by syan on 23/01/2024.
//  Copyright © 2024 Syan. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let isoFormatter = {
        // 2022-04-30T00:00:00.000Z
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        return isoFormatter
    }()
}
