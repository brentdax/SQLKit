//
//  PGTimestamp.swift
//  LittlinkRouterPerfect
//
//  Created by Brent Royal-Gordon on 12/4/16.
//
//

import Foundation

public struct PGTimestamp {
    public static var distantPast = PGTimestamp(date: .distantPast)
    public static var distantFuture = PGTimestamp(date: .distantFuture)
    
    public init(date: PGDate = PGDate(), time: PGTime = PGTime()) {
        self.date = date
        self.time = time
    }
    
    public var date: PGDate
    public var time: PGTime
}

extension PGTimestamp {
    public init(_ date: Date) {
        switch date {
        case Date.distantPast:
            self.init(date: .distantPast)
        case Date.distantFuture:
            self.init(date: .distantFuture)
        default:
            let components = Calendar.gregorian.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond, .timeZone], from: date)
            self.init(components)!
        }
    }
    
    public init?(_ components: DateComponents) {
        guard let date = PGDate(components), let time = PGTime(components) else {
            return nil
        }
        
        self.init(date: date, time: time)
    }
}

extension DateComponents {
    public init?(_ timestamp: PGTimestamp) {
        guard let dateComps = DateComponents(timestamp.date) else {
            return nil
        }
        let timeComps = DateComponents(timestamp.time)
        
        self.init(timeZone: timeComps.timeZone, era: dateComps.era, year: dateComps.year, month: dateComps.month, day: dateComps.day, hour: timeComps.hour, minute: timeComps.minute, second: timeComps.second, nanosecond: timeComps.nanosecond)
    }
}

extension Date {
    public init?(_ timestamp: PGTimestamp) {
        guard let comps = DateComponents(timestamp) else {
            return nil
        }
        guard let date = Calendar.gregorian.date(from: comps) else {
            return nil
        }
        self = date
    }
}