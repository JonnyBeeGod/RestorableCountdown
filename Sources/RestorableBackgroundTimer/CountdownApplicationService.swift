//
//  CountdownApplicationService.swift
//  RestorableBackgroundTimer
//
//  Created by Jonas Reichert on 23.12.19.
//

import Foundation
import UIKit // TODO: this class is UIKit dependent which breaks the platforms constraint

/// hooks into lifecycle methods to safely invalidate a timer when application is going into background and restoring a timer when application goes into foreground again
protocol CountdownApplicationServiceProtocol {
    func register()
}

class CountdownApplicationService: CountdownApplicationServiceProtocol {
    
    private let notificationCenter: NotificationCenter
    weak var countdown: CountdownBackgroundRestorable?
    
    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
    
    func register() {
        notificationCenter.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
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
