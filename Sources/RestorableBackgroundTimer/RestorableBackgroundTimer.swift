import Foundation

protocol CountdownDelegate: class {
    func timerDidFire(with currentTime: DateComponents)
    func timerDidFinish()
}

protocol Countdownable {
    func startCountdown(with length: DateComponents)
    func startCountdown(with finishedDate: Date)
}

class Countdown: Countdownable {
    
    private weak var delegate: CountdownDelegate?
    private var timer: Timer?
    private var finishedDate: Date!
    private let fireInterval: TimeInterval
    private let tolerance: Double
    
    init(delegate: CountdownDelegate, with fireInterval: TimeInterval = 0.1, and tolerance: Double = 0.05) {
        self.delegate = delegate
        self.fireInterval = fireInterval
        self.tolerance = tolerance
    }
    
    func startCountdown(with length: DateComponents) {
        startCountdown(with: calculateDate(for: length))
    }
    
    func startCountdown(with finishedDate: Date) {
        self.finishedDate = finishedDate
        
        configureAndStartTimer()
    }
    
    @objc
    private func timerTick() {
        if Date() > finishedDate {
            timer?.invalidate()
            delegate?.timerDidFinish()
        } else {
            delegate?.timerDidFire(with: calculateDateComponentsForCurrentTime())
        }
    }
    
    private func configureAndStartTimer() {
        let timer = Timer(timeInterval: fireInterval, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        timer.tolerance = tolerance
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)
        self.timer = timer
    }
    
    private func calculateDateComponentsForCurrentTime() -> DateComponents {
        let interval = finishedDate.timeIntervalSince(Date())
        return DateComponents.dateComponents(for: interval)
    }
    
    private func calculateDate(for length: DateComponents) -> Date {
        return Date().addingTimeInterval(length.timeInterval())
    }
    
}
