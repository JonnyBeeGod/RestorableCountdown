//
//  CountdownConfiguration.swift
//  RestorableBackgroundTimer
//
//  Created by Jonas Reichert on 23.12.19.
//

import Foundation

public struct CountdownConfiguration {
    let fireInterval: TimeInterval
    let tolerance: Double
    let maxCountdownDuration: TimeInterval
    let minCountdownDuration: TimeInterval
    let countdownDuration: TimeInterval
    
    public init(fireInterval: TimeInterval = 0.1, tolerance: Double = 0.05, maxCountdownDuration: TimeInterval = 30 * 60, minCountdownDuration: TimeInterval = 15, defaultCountdownDuration: TimeInterval = 90) {
        assert(minCountdownDuration < defaultCountdownDuration && defaultCountdownDuration < maxCountdownDuration, "invalid input. make sure your countdownDuration is between min and max duration")
        self.fireInterval = fireInterval
        self.tolerance = tolerance
        self.maxCountdownDuration = maxCountdownDuration
        self.minCountdownDuration = minCountdownDuration
        self.countdownDuration = defaultCountdownDuration
    }
}