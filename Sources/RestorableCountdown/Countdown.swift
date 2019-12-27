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
    var delegate: CountdownDelegate? { get set }
    
    func startCountdown()
    
    /// returns the current time of the countdown until it is finished
    ///
    /// on a countdown that has not been started yet this is the same as `totalRunTime`. After that it is the `totalRunTime`- the elapsed time since starting the countdown
    func timeToFinish() -> DateComponents?
    
    /// returns the total runtime of the countdown
    ///
    /// this takes any increases or decreases of the runtime into account
    func totalRunTime() -> DateComponents?
    
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
    private var countdownDuration: TimeInterval
    private let countdownNotificationBuilder: CountdownNotificationBuilding
    
    private let defaults: UserDefaults
    private var countdownApplicationService: CountdownApplicationServiceProtocol
    
    /// the injected UNUserNotificationCenter if you want to use local notifications for your timer
    /// UNUserNotificationCenter needs to be injected, from outside to the framework. Passing .current() leads to crashes here
    /// See this SO post: https://stackoverflow.com/a/49559863
    private let userNotificationCenter: UserNotificationCenter?
    private var notificationContent: UNNotificationContent?
    
    public convenience init(delegate: CountdownDelegate? = nil, countdownConfiguration: CountdownConfiguration = CountdownConfiguration(), userNotificationCenter: UNUserNotificationCenter? = nil, notificationContent: UNNotificationContent? = nil) {
        self.init(delegate: delegate, countdownConfiguration: countdownConfiguration, defaults: UserDefaults(suiteName: UserDefaultsConstants.suiteName.rawValue) ?? .standard, countdownApplicationService: CountdownApplicationService(), userNotificationCenter: userNotificationCenter, notificationContent: notificationContent)
    }
    
    init(delegate: CountdownDelegate? = nil, countdownConfiguration: CountdownConfiguration = CountdownConfiguration(), countdownNotificationBuilder: CountdownNotificationBuilding = CountdownNotificationBuilder(), defaults: UserDefaults = UserDefaults(suiteName: UserDefaultsConstants.suiteName.rawValue) ?? .standard, countdownApplicationService: CountdownApplicationServiceProtocol = CountdownApplicationService(), userNotificationCenter: UserNotificationCenter? = nil, notificationContent: UNNotificationContent? = nil) {
        self.delegate = delegate
        self.countdownConfiguration = countdownConfiguration
        self.countdownDuration = countdownConfiguration.countdownDuration
        self.countdownNotificationBuilder = countdownNotificationBuilder
        self.defaults = defaults
        self.countdownApplicationService = countdownApplicationService
        self.userNotificationCenter = userNotificationCenter
        self.notificationContent = notificationContent
        self.countdownApplicationService.countdown = self
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
    
    private func cleanupSavedFinishedDate() {
        defaults.set(nil, forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue)
    }
}

extension Countdown: Countdownable {
    
    public func startCountdown() {
        let calculatedDate = Date().addingTimeInterval(countdownConfiguration.countdownDuration)
        startCountdown(with: calculatedDate)
    }
    
    public func timeToFinish() -> DateComponents? {
        return calculateDateComponentsForCurrentTime()
    }
    
    public func totalRunTime() -> DateComponents? {
        return DateComponents.dateComponents(for: countdownDuration)
    }
    
    public func increaseTime(by seconds: TimeInterval) {
        increaseOrDecreaseTime(increase: true, by: seconds)
    }
    
    public func decreaseTime(by seconds: TimeInterval) {
        increaseOrDecreaseTime(increase: false, by: seconds)
    }
    
    private func increaseOrDecreaseTime(increase: Bool, by seconds: TimeInterval) {
        let mutatedRuntime = increase ? countdownDuration + seconds : countdownDuration - seconds
        
        guard mutatedRuntime >= countdownConfiguration.minCountdownDuration && mutatedRuntime <= countdownConfiguration.maxCountdownDuration else {
            return
        }
        
        finishedDate = finishedDate?.addingTimeInterval(increase ? seconds : -seconds)
        countdownDuration = mutatedRuntime
        scheduleLocalNotification()
    }
    
    public func skipRunningCountdown() {
        finishCountdown()
        
        // TODO: only remove the notification requests from this library, not the whole app ?!
        userNotificationCenter?.removeAllPendingNotificationRequests()
    }
    
    func startCountdown(with finishedDate: Date) {
        self.finishedDate = finishedDate
        
        configureAndStartTimer()
        scheduleLocalNotification()
        countdownApplicationService.register()
    }
    
    func startCountdown(with length: DateComponents) {
        startCountdown(with: calculateDate(for: length))
    }
    
    private func scheduleLocalNotification() {
        guard let notificationContent = notificationContent, let userNotificationCenter = userNotificationCenter, let finishedDate = finishedDate else {
            return
        }
        
        let request = countdownNotificationBuilder.build(content: notificationContent, scheduledDate: finishedDate)
        
        userNotificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
                case .authorized, .provisional:
                userNotificationCenter.removeAllPendingNotificationRequests()
                userNotificationCenter.add(request, withCompletionHandler: nil)
            default:
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
        guard let finishedDate = finishedDate, Date() < finishedDate, let calculateDateComponentsForCurrentTime = calculateDateComponentsForCurrentTime() else {
            finishCountdown()
            return
        }
        
        delegate?.timerDidFire(with: calculateDateComponentsForCurrentTime)
    }
    
    private func finishCountdown() {
        timer?.invalidate()
        delegate?.timerDidFinish()
        finishedDate = nil
        
        cleanupSavedFinishedDate()
        countdownApplicationService.deregister()
    }
    
    private func calculateDateComponentsForCurrentTime() -> DateComponents? {
        let currentFinishedDate = finishedDate ?? Date().addingTimeInterval(countdownDuration)
        guard currentFinishedDate.compare(Date()) != .orderedAscending else {
            return nil
        }
        
        let interval = currentFinishedDate.timeIntervalSince(Date())
        return DateComponents.dateComponents(for: interval)
    }
    
    private func calculateDate(for length: DateComponents) -> Date {
        return Date().addingTimeInterval(length.timeInterval())
    }
}
