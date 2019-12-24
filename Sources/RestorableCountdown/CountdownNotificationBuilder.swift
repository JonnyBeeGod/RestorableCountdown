//
//  CountDownNotificationBuilder.swift
//  RestorableBackgroundTimer
//
//  Created by Jonas Reichert on 23.12.19.
//

import Foundation
import UserNotifications

protocol CountdownNotificationBuilding: class {
    func build(content: UNNotificationContent, scheduledDate: Date) -> UNNotificationRequest
}

class CountdownNotificationBuilder: CountdownNotificationBuilding {
    
    private let calendar: Calendar
    
    init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
    }
    
    func build(content: UNNotificationContent, scheduledDate: Date) -> UNNotificationRequest {
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponentsFromTimerFinishedDate(finishedDate: scheduledDate), repeats: false)
        return UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    }
    
    private func notificationDateComponentsFromTimerFinishedDate(finishedDate: Date) -> DateComponents {
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: finishedDate)
    }
}
