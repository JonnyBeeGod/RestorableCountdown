//
//  UserNotificationProtocol.swift
//  RestorableCountdown
//
//  Created by Jonas Reichert on 25.12.19.
//

import UserNotifications

protocol UserNotificationCenter {
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    func removeAllPendingNotificationRequests()
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
}

extension UNUserNotificationCenter: UserNotificationCenter {}
