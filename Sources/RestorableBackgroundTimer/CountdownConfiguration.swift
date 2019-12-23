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
    
    public init(fireInterval: TimeInterval = 0.1, tolerance: Double = 0.05, maxCountdownDuration: TimeInterval = 30 * 60, minCountdownDuration: TimeInterval = 15) {
        self.fireInterval = fireInterval
        self.tolerance = tolerance
        self.maxCountdownDuration = maxCountdownDuration
        self.minCountdownDuration = minCountdownDuration
    }
}
