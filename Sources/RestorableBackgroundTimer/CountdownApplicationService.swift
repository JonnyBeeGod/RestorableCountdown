//
//  CountdownApplicationService.swift
//  RestorableBackgroundTimer
//
//  Created by Jonas Reichert on 23.12.19.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// hooks into lifecycle methods to safely invalidate a timer when application is going into background and restoring a timer when application goes into foreground again
protocol CountdownApplicationServiceProtocol {
    func register()
    func deregister()
}

class CountdownApplicationService: CountdownApplicationServiceProtocol {
    
    private let notificationCenter: NotificationCenter
    weak var countdown: CountdownBackgroundRestorable?
    
    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
    
    func register() {
        #if canImport(UIKit)
        notificationCenter.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        #endif
    }
    
    func deregister() {
        #if canImport(UIKit)
        notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        #endif
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
