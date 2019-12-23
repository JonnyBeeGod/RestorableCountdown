//
//  Notification+Extension.swift
//  RestorableBackgroundTimer
//
//  Created by Jonas Reichert on 23.12.19.
//

import Foundation

extension Notification.Name {
    static let willResignActive = Notification.Name("willResignActive")
    static let didBecomeActive = Notification.Name("didBecomeActive")
}
