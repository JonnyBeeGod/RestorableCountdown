import Foundation
import UserNotifications

public protocol CountdownDelegate: class {
    func timerDidFire(with currentTime: DateComponents)
    func timerDidFinish()
}

protocol CountdownBackgroundRestorable: class {
    func invalidate()
    func restore()
}

public protocol Countdownable {
    func startCountdown(with length: DateComponents, with userNotificationRequest: UNNotificationRequest?)
    func startCountdown(with finishedDate: Date, with userNotificationRequest: UNNotificationRequest?)
    
    func currentRuntime() -> DateComponents?
    
    /// increases the duration of the countdown by the supplied number of seconds
    ///
    /// if the supplied number of `seconds` added on the current countdown duration exceeds  `maxCountdownDuration`, this method returns without increasing time
    func increaseTime(by seconds: TimeInterval)
    
    /// decreases the duration of the countdown by the supplied number of seconds
    ///
    /// if the current remaining `seconds` of the countdown are smaller than the supplied number of seconds, this method just returns without decreasing the time
    func decreaseTime(by seconds: TimeInterval)
    
    func skipRunningCountdown()
}

public class Countdown: CountdownBackgroundRestorable {
    
    private weak var delegate: CountdownDelegate?
    
    private var finishedDate: Date?
    private var timer: Timer?
    
    private let fireInterval: TimeInterval
    private let tolerance: Double
    private let maxCountdownDuration: TimeInterval
    private let minCountdownDuration: TimeInterval
    
    private let defaults: UserDefaults
    private let countdownApplicationService: CountdownApplicationServiceProtocol
    
    /// the injected UNUserNotificationCenter if you want to use local notifications for your timer
    /// UNUserNotificationCenter needs to be injected, from outside to the framework. Passing .current() leads to crashes here
    /// See this SO post: https://stackoverflow.com/a/49559863
    private let userNotificationCenter: UNUserNotificationCenter?
    private var notificationRequest: UNNotificationRequest?
    
    public convenience init(delegate: CountdownDelegate, countdownConfiguration: CountdownConfiguration = CountdownConfiguration(), userNotificationCenter: UNUserNotificationCenter? = nil) {
        self.init(delegate: delegate, countdownConfiguration: countdownConfiguration, defaults: UserDefaults(suiteName: UserDefaultsConstants.suiteName.rawValue) ?? .standard, userNotificationCenter: userNotificationCenter)
    }
    
    convenience init(delegate: CountdownDelegate, countdownConfiguration: CountdownConfiguration = CountdownConfiguration(), defaults: UserDefaults, countdownApplicationService: CountdownApplicationService = CountdownApplicationService(), userNotificationCenter: UNUserNotificationCenter? = nil) {
        self.init(delegate: delegate,
                  fireInterval: countdownConfiguration.fireInterval,
                  tolerance: countdownConfiguration.tolerance,
                  maxCountdownDuration: countdownConfiguration.maxCountdownDuration,
                  minCountdownDuration: countdownConfiguration.minCountdownDuration,
                  defaults: defaults,
                  countdownApplicationService: countdownApplicationService,
                  userNotificationCenter: userNotificationCenter)
        
        countdownApplicationService.countdown = self
    }
    
    init(delegate: CountdownDelegate, fireInterval: TimeInterval, tolerance: Double, maxCountdownDuration: TimeInterval, minCountdownDuration: TimeInterval, defaults: UserDefaults, countdownApplicationService: CountdownApplicationServiceProtocol, userNotificationCenter: UNUserNotificationCenter?) {
        self.delegate = delegate
        self.fireInterval = fireInterval
        self.tolerance = tolerance
        self.maxCountdownDuration = maxCountdownDuration
        self.minCountdownDuration = minCountdownDuration
        self.defaults = defaults
        self.countdownApplicationService = countdownApplicationService
        self.userNotificationCenter = userNotificationCenter
    }
    
    func invalidate() {
        timer?.invalidate()
        defaults.set(finishedDate, forKey: UserDefaultsConstants.countdownFinishedDate.rawValue)
        
        finishedDate = nil
    }
    
    func restore() {
        guard let finishedDate = defaults.value(forKey: UserDefaultsConstants.countdownFinishedDate.rawValue) as? Date else {
            return
        }
        
        startCountdown(with: finishedDate)
        cleanupSavedFinishedDate()
    }
    
    private func cleanupSavedFinishedDate() {
        defaults.set(nil, forKey: UserDefaultsConstants.countdownFinishedDate.rawValue)
    }
}

extension Countdown: Countdownable {
    
    public func startCountdown(with length: DateComponents, with userNotificationRequest: UNNotificationRequest? = nil) {
        startCountdown(with: calculateDate(for: length), with: userNotificationRequest)
    }
    
    public func startCountdown(with finishedDate: Date, with userNotificationRequest: UNNotificationRequest? = nil) {
        self.notificationRequest = userNotificationRequest
        self.finishedDate = finishedDate
        
        configureAndStartTimer()
        scheduleLocalNotification()
    }
    
    public func currentRuntime() -> DateComponents? {
        return calculateDateComponentsForCurrentTime()
    }
    
    public func increaseTime(by seconds: TimeInterval) {
        let currentSavedDefaultCountdownRuntime = defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        let increasedRuntime = currentSavedDefaultCountdownRuntime + seconds
        
        guard increasedRuntime <=  maxCountdownDuration else {
            return
        }
        
        finishedDate = finishedDate?.addingTimeInterval(seconds)
        defaults.set(increasedRuntime, forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        scheduleLocalNotification()
    }
    
    public func decreaseTime(by seconds: TimeInterval) {
        let currentSavedDefaultCountdownRuntime = defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        let decreasedRuntime = currentSavedDefaultCountdownRuntime - seconds
        
        guard decreasedRuntime > minCountdownDuration else {
            return
        }
        
        finishedDate = finishedDate?.addingTimeInterval(-seconds)
        defaults.set(decreasedRuntime, forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        scheduleLocalNotification()
    }
    
    public func skipRunningCountdown() {
        finishCountdown()
        
        if let userNotificationCenter = userNotificationCenter {
            // TODO: only remove the notification requests from this library, not the whole app ?!
            userNotificationCenter.removeAllPendingNotificationRequests()
        }
    }
    
    private func scheduleLocalNotification() {
        guard let notificationRequest = notificationRequest, let userNotificationCenter = userNotificationCenter else {
            return
        }
        
        userNotificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .denied, .notDetermined:
                return
            case .authorized, .provisional:
                userNotificationCenter.removeAllPendingNotificationRequests()
                userNotificationCenter.add(notificationRequest)
            @unknown default:
                return
            }
        }
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
            finishCountdown()
            return
        }
        
        if Date() > finishedDate {
            finishCountdown()
        } else {
            delegate?.timerDidFire(with: calculateDateComponentsForCurrentTime)
        }
    }
    
    private func finishCountdown() {
        timer?.invalidate()
        delegate?.timerDidFinish()
        finishedDate = nil
        
        cleanupSavedFinishedDate()
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
