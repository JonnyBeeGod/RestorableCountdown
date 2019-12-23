//
//  DateComponents+Extension.swift
//  RestorableBackgroundTimer
//
//  Created by Jonas Reichert on 21.12.19.
//

import Foundation

extension DateComponents {
    /// returns DateComponents for a supplied TimeInterval
    ///
    /// since this method is agnostic of Date and Calendar, it is only possible to calculate up to days, not months.
    static func dateComponents(for timeinterval: TimeInterval) -> DateComponents {
        var result = DateComponents()
        let days = Int(timeinterval / 60 / 60 / 24)
        let hours = Int(timeinterval / 60 / 60) % 24
        let minutes = Int(timeinterval / 60) % 60
        let seconds = Int(timeinterval) % 60
        result.day = days
        result.hour = hours
        result.minute = minutes
        result.second = seconds
        return result
    }
    
    /// calculates a TimeInterval
    ///
    /// since this method is agnostic of Date and Calendar, it is only possible to calculate up to days, not months.
    func timeInterval() -> TimeInterval {
        let seconds = (self.second ?? 0)
        let minutes = (self.minute ?? 0) * 60
        let hours = (self.hour ?? 0) * 60 * 60
        let days = (self.day ?? 0) * 60 * 60 * 24
        
        return TimeInterval(Double(seconds + minutes + hours + days))
    }
}

