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

public protocol Countdownable: class {
    func startCountdown(with userNotificationRequest: UNNotificationRequest?)
    
    func currentRuntime() -> DateComponents?
    
    /// increases the duration of the countdown by the supplied number of seconds
    ///
    /// if the supplied number of `seconds` added on the current countdown duration exceeds  `countdownConfiguration.maxCountdownDuration`, this method returns without increasing time
    func increaseTime(by seconds: TimeInterval)
    
    /// decreases the duration of the countdown by the supplied number of seconds
    ///
    /// if the current remaining `seconds` of the countdown are smaller than the supplied number of seconds, this method just returns without decreasing the time
    func decreaseTime(by seconds: TimeInterval)
    
    func skipRunningCountdown()
}

public class Countdown: CountdownBackgroundRestorable {
    
    public weak var delegate: CountdownDelegate?
    
    private var finishedDate: Date?
    private var timer: Timer?
    
    private let countdownConfiguration: CountdownConfiguration
    
    private let defaults: UserDefaults
    private var countdownApplicationService: CountdownApplicationServiceProtocol
    
    /// the injected UNUserNotificationCenter if you want to use local notifications for your timer
    /// UNUserNotificationCenter needs to be injected, from outside to the framework. Passing .current() leads to crashes here
    /// See this SO post: https://stackoverflow.com/a/49559863
    private let userNotificationCenter: UNUserNotificationCenter?
    private var notificationRequest: UNNotificationRequest?
    
    public convenience init(delegate: CountdownDelegate? = nil, countdownConfiguration: CountdownConfiguration = CountdownConfiguration(), userNotificationCenter: UNUserNotificationCenter? = nil) {
        self.init(delegate: delegate, countdownConfiguration: countdownConfiguration, defaults: UserDefaults(suiteName: UserDefaultsConstants.suiteName.rawValue) ?? .standard, countdownApplicationService: CountdownApplicationService(), userNotificationCenter: userNotificationCenter)
    }
    
    init(delegate: CountdownDelegate? = nil, countdownConfiguration: CountdownConfiguration = CountdownConfiguration(), defaults: UserDefaults = UserDefaults(suiteName: UserDefaultsConstants.suiteName.rawValue) ?? .standard, countdownApplicationService: CountdownApplicationServiceProtocol = CountdownApplicationService(), userNotificationCenter: UNUserNotificationCenter? = nil) {
        self.delegate = delegate
        self.countdownConfiguration = countdownConfiguration
        self.defaults = defaults
        self.countdownApplicationService = countdownApplicationService
        self.userNotificationCenter = userNotificationCenter
        self.countdownApplicationService.countdown = self
        
        persistCountdownRuntime(configuration: countdownConfiguration)
    }
    
    func invalidate() {
        timer?.invalidate()
        defaults.set(finishedDate, forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue)
    }
    
    func restore() {
        guard let finishedDate = defaults.value(forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue) as? Date else {
            return
        }
        
        startCountdown(with: finishedDate)
        cleanupSavedFinishedDate()
    }
    
    private func persistCountdownRuntime(configuration: CountdownConfiguration) {
        defaults.set(configuration.countdownDuration, forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
    }
    
    private func cleanupSavedFinishedDate() {
        defaults.set(nil, forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue)
    }
}

extension Countdown: Countdownable {
    
    public func startCountdown(with userNotificationRequest: UNNotificationRequest? = nil) {
        let calculatedDate = Date().addingTimeInterval(countdownConfiguration.countdownDuration)
        startCountdown(with: calculatedDate, with: userNotificationRequest)
    }
    
    public func currentRuntime() -> DateComponents? {
        return calculateDateComponentsForCurrentTime()
    }
    
    public func increaseTime(by seconds: TimeInterval) {
        let currentSavedDefaultCountdownRuntime = defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        let increasedRuntime = currentSavedDefaultCountdownRuntime + seconds
        
        guard increasedRuntime <=  countdownConfiguration.maxCountdownDuration else {
            return
        }
        
        finishedDate = finishedDate?.addingTimeInterval(seconds)
        defaults.set(increasedRuntime, forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        scheduleLocalNotification()
    }
    
    public func decreaseTime(by seconds: TimeInterval) {
        let currentSavedDefaultCountdownRuntime = defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue)
        let decreasedRuntime = currentSavedDefaultCountdownRuntime - seconds
        
        guard decreasedRuntime > countdownConfiguration.minCountdownDuration else {
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
    
    func startCountdown(with finishedDate: Date, with userNotificationRequest: UNNotificationRequest? = nil) {
        self.notificationRequest = userNotificationRequest
        self.finishedDate = finishedDate
        
        configureAndStartTimer()
        scheduleLocalNotification()
        countdownApplicationService.register()
    }
    
    func startCountdown(with length: DateComponents, with userNotificationRequest: UNNotificationRequest? = nil) {
        startCountdown(with: calculateDate(for: length), with: userNotificationRequest)
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
        let timer = Timer(timeInterval: countdownConfiguration.fireInterval, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
        timer.tolerance = countdownConfiguration.tolerance
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
        countdownApplicationService.deregister()
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
