//
//  CountdownApplicationService.swift
//  RestorableBackgroundTimer
//
//  Created by Jonas Reichert on 23.12.19.
//

import Foundation

/// hooks into lifecycle methods to safely invalidate a timer when application is going into background and restoring a timer when application goes into foreground again
protocol CountdownApplicationServiceProtocol {
    func register()
}

class CountdownApplicationService: CountdownApplicationServiceProtocol {
    
    private let notificationCenter: NotificationCenter
    
    private weak var countdown: CountdownBackgroundRestorable?
    
    init(notificationCenter: NotificationCenter = .default, countdown: CountdownBackgroundRestorable) {
        self.notificationCenter = notificationCenter
        self.countdown = countdown
    }
    
    func register() {
        notificationCenter.addObserver(self, selector: #selector(willResignActive), name: Notification.Name
            .willResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didBecomeActive), name: Notification.Name
        .didBecomeActive, object: nil)
    }
    
    @objc
    func willResignActive() {
        // save current timer state and invalidate
        countdown?.invalidate()
    }
    
    @objc
    func didBecomeActive() {
        // restore timer state
        countdown?.restore()
    }
}
