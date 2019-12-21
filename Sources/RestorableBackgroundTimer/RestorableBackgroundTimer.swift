import Foundation

protocol CountdownDelegate: class {
    func timerDidFire(with currentTime: DateComponents)
    func timerDidFinish()
}

protocol Countdownable {
    func startCountdown(with length: DateComponents)
    func startCountdown(with finishedDate: Date)
    
    func currentRuntime() -> DateComponents?
    
    /// increases the duration of the countdown by the supplied number of seconds
    ///
    /// if the supplied number of `seconds` added on the current countdown duration exceeds  `maxCountdownDuration`, this method returns without increasing time
    func increaseTime(by seconds: TimeInterval)
    
    /// decreases the duration of the countdown by the supplied number of seconds
    ///
    /// if the current remaining `seconds` of the countdown are smaller than the supplied number of seconds, this method just returns without decreasing the time
    func decreaseTime(by seconds: TimeInterval)
}

class Countdown {
    
    private weak var delegate: CountdownDelegate?
    
    private var timer: Timer?
    private var finishedDate: Date?
    private let fireInterval: TimeInterval
    private let tolerance: Double
    private let maxCountdownDuration: TimeInterval
    private let minCountdownDuration: TimeInterval
    private let defaults: UserDefaults
    
    init(delegate: CountdownDelegate, fireInterval: TimeInterval = 0.1, tolerance: Double = 0.05, maxCountdownDuration: TimeInterval = 30 * 60, minCountdownDuration: TimeInterval = 15, defaults: UserDefaults = UserDefaults(suiteName: "RestorableCountdownDefaults") ?? .standard) {
        self.delegate = delegate
        self.fireInterval = fireInterval
        self.tolerance = tolerance
        self.maxCountdownDuration = maxCountdownDuration
        self.minCountdownDuration = minCountdownDuration
        self.defaults = defaults
    }
}

extension Countdown: Countdownable {
    func startCountdown(with length: DateComponents) {
        startCountdown(with: calculateDate(for: length))
    }
    
    func startCountdown(with finishedDate: Date) {
        self.finishedDate = finishedDate
        
        configureAndStartTimer()
    }
    
    func currentRuntime() -> DateComponents? {
        return calculateDateComponentsForCurrentTime()
    }
    
    func increaseTime(by seconds: TimeInterval) {
        let currentSavedDefaultCountdownRuntime = defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        let increasedRuntime = currentSavedDefaultCountdownRuntime + seconds
        
        guard increasedRuntime <=  maxCountdownDuration else {
            return
        }
        
        finishedDate = finishedDate?.addingTimeInterval(seconds)
        defaults.set(increasedRuntime, forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
    }
    
    func decreaseTime(by seconds: TimeInterval) {
        let currentSavedDefaultCountdownRuntime = defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        let decreasedRuntime = currentSavedDefaultCountdownRuntime - seconds
        
        guard decreasedRuntime > minCountdownDuration else {
            return
        }
        
        finishedDate = finishedDate?.addingTimeInterval(-seconds)
        defaults.set(decreasedRuntime, forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
    }
    
    private func configureAndStartTimer() {
        let timer = Timer(timeInterval: fireInterval, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        timer.tolerance = tolerance
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        self.timer = timer
    }
    
    @objc
    private func timerTick() {
        guard let finishedDate = finishedDate, let calculateDateComponentsForCurrentTime = calculateDateComponentsForCurrentTime() else {
            timer?.invalidate()
            delegate?.timerDidFinish()
            return
        }
        
        if Date() > finishedDate {
            timer?.invalidate()
            delegate?.timerDidFinish()
        } else {
            delegate?.timerDidFire(with: calculateDateComponentsForCurrentTime)
        }
    }
    
    private func calculateDateComponentsForCurrentTime() -> DateComponents? {
        guard let finishedDate = finishedDate, finishedDate.compare(Date()) != .orderedAscending else {
            return nil
        }
        
        let interval = finishedDate.timeIntervalSince(Date())
        return DateComponents.dateComponents(for: interval)
    }
    
    private func calculateDate(for length: DateComponents) -> Date {
        return Date().addingTimeInterval(length.timeInterval())
    }
}
