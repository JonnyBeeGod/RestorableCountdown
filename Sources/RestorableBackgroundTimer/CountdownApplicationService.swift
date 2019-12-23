//
//  CountdownApplicationService.swift
//  RestorableBackgroundTimer
//
//  Created by Jonas Reichert on 23.12.19.
//

import Foundation

protocol CountdownApplicationServiceProtocol {
    func register()
}

class CountdownApplicationService: CountdownApplicationServiceProtocol {
    
    private let notificationCenter: NotificationCenter
    private weak var timer: Timer?
    
    init(notificationCenter: NotificationCenter = .default, defaults: UserDefaults = UserDefaults(suiteName: UserDefaultsConstants.suiteName.rawValue) ?? .standard, timer: Timer) {
        self.notificationCenter = notificationCenter
        self.timer = timer
    }
    
    func register() {
        notificationCenter.addObserver(self, selector: #selector(willResignActive), name: Notification.Name
            .willResignActive, object: nil)
    }
    
    @objc
    func willResignActive() {
        timer?.invalidate()
    }
}
