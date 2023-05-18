//
//  Calendar+SY.swift
//  TorrentAdder
//
//  Created by Stanislas Chevallier on 30/11/2018.
//  Copyright © 2018 Syan. All rights reserved.
//

import UIKit

extension Calendar {
    
    func dateCombining(day: Date?, time: Date?) -> Date? {
        guard let day = day, let time = time else { return nil }
        var compsDate = dateComponents(Set([Calendar.Component.year, .month, .day]), from: day)
        let compsTime = dateComponents(Set([Calendar.Component.hour, .minute]), from: time)
        compsDate.hour = compsTime.hour
        compsDate.minute = compsTime.minute
        return date(from: compsDate)
    }
    
    func dateCombining(year: Date?, dayAndTime: Date?) -> Date? {
        guard let year = year, let dayAndTime = dayAndTime else { return nil }
        var compsAll  = dateComponents(Set([Calendar.Component.month, .day, .hour, .minute]), from: dayAndTime)
        let compsYear = dateComponents(Set([Calendar.Component.year]), from: year)
        compsAll.year = compsYear.year
        return date(from: compsAll)
    }
    
}
