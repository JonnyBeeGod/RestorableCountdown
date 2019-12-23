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
    private let defaults: UserDefaults
    
    private weak var countdown: CountdownRestorable?
    
    init(notificationCenter: NotificationCenter = .default, defaults: UserDefaults = UserDefaults(suiteName: UserDefaultsConstants.suiteName.rawValue) ?? .standard, countdown: CountdownRestorable) {
        self.notificationCenter = notificationCenter
        self.defaults = defaults
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
        guard let finishedDate = countdown?.finishedDate else {
            return
        }
        
        defaults.set(finishedDate, forKey: UserDefaultsConstants.countdownFinishedDate.rawValue)
        countdown?.invalidate()
    }
    
    @objc
    func didBecomeActive() {
        // restore timer state
        guard let finishedDate = defaults.value(forKey: UserDefaultsConstants.countdownFinishedDate.rawValue) as? Date else {
            return
        }
        
        countdown?.restore(with: finishedDate)
    }
}
