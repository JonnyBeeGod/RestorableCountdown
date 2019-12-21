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
    
    init(delegate: CountdownDelegate, fireInterval: TimeInterval = 0.1, tolerance: Double = 0.05, maxCountdownDuration: TimeInterval = 30 * 60) {
        self.delegate = delegate
        self.fireInterval = fireInterval
        self.tolerance = tolerance
        self.maxCountdownDuration = maxCountdownDuration
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
        guard let timer = timer else {
            return
        }
        
        
    }
    
    func decreaseTime(by seconds: TimeInterval) {
        
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
        guard let finishedDate = finishedDate else {
            return nil
        }
        
        let interval = finishedDate.timeIntervalSince(Date())
        return DateComponents.dateComponents(for: interval)
    }
    
    private func calculateDate(for length: DateComponents) -> Date {
        return Date().addingTimeInterval(length.timeInterval())
    }
}
