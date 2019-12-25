import XCTest
import UserNotifications
@testable import RestorableCountdown

final class CountdownTests: XCTestCase {
    
    func testStartCountDownTimerDidFireItsCallbacks() {
        var timerDidFireExpectation: XCTestExpectation!
        var timerDidFinishExpectation: XCTestExpectation!
        
        timerDidFireExpectation = self.expectation(description: "timerDidFire")
        timerDidFireExpectation.expectedFulfillmentCount = 5 // at least 10 time fired combined because 2 tests start countdowns
        timerDidFireExpectation.assertForOverFulfill = false
        
        timerDidFinishExpectation = self.expectation(description: "timerDidFinish")
        timerDidFireExpectation.expectedFulfillmentCount = 1 // exactly 2 times fired combined because 2 tests start the countdowns
        timerDidFinishExpectation.assertForOverFulfill = true
        
        let mockDelegate = MockCountdownDelegate()
        mockDelegate.timerDidFinishExpectation = timerDidFinishExpectation
        mockDelegate.timerDidFireExpectation = timerDidFireExpectation
        
        let countdown = Countdown(delegate: mockDelegate, defaults: MockUserDefaults())
        countdown.startCountdown(with: Date().addingTimeInterval(1))
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testStartCountDown2TimerDidFireItsCallbacks() {
        var timerDidFireExpectation: XCTestExpectation!
        var timerDidFinishExpectation: XCTestExpectation!
        
        timerDidFireExpectation = self.expectation(description: "timerDidFire")
        timerDidFireExpectation.expectedFulfillmentCount = 5 // at least 10 time fired combined because 2 tests start countdowns
        timerDidFireExpectation.assertForOverFulfill = false
        
        timerDidFinishExpectation = self.expectation(description: "timerDidFinish")
        timerDidFireExpectation.expectedFulfillmentCount = 1 // exactly 2 times fired combined because 2 tests start the countdowns
        timerDidFinishExpectation.assertForOverFulfill = true
        
        let mockDelegate = MockCountdownDelegate()
        mockDelegate.timerDidFinishExpectation = timerDidFinishExpectation
        mockDelegate.timerDidFireExpectation = timerDidFireExpectation
        
        let timer = Countdown(delegate: mockDelegate, defaults: MockUserDefaults())
        
        var components = DateComponents()
        components.second = 1
        timer.startCountdown(with: components)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testcurrentRuntime() {
        let mockDelegate = MockCountdownDelegate()
        let timer = Countdown(delegate: mockDelegate, defaults: MockUserDefaults())
        
        XCTAssertNil(timer.currentRuntime())
        timer.startCountdown(with: Date().addingTimeInterval(2))
        XCTAssertNotNil(timer.currentRuntime())
        
        guard let runtime = timer.currentRuntime() else {
            XCTFail("timer should have a run time")
            return
        }
        
        var expectedResult = DateComponents()
        expectedResult.second = 1
        
        XCTAssertEqual(Double(runtime.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
    }
    
    func testIncreaseCountdownTime() {
        let mockDelegate = MockCountdownDelegate()
        let timer = Countdown(delegate: mockDelegate, defaults: MockUserDefaults())
        timer.startCountdown(with: Date().addingTimeInterval(2))
        
        var expectedResult = DateComponents()
        expectedResult.second = 1
        
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
        
        timer.increaseTime(by: 3)
        expectedResult.second = 4
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
    }
    
    func testIncreaseCountdownTimeOverMaxTime() {
        let mockDelegate = MockCountdownDelegate()
        let defaults = MockUserDefaults()
        let configuration = CountdownConfiguration(maxCountdownDuration: 2, minCountdownDuration: 0, defaultCountdownDuration: 1)
        let timer = Countdown(delegate: mockDelegate, countdownConfiguration: configuration, defaults: defaults)
        timer.startCountdown(with: Date().addingTimeInterval(2))
        
        var expectedResult = DateComponents()
        expectedResult.second = 1
        
        XCTAssertEqual(defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue), 1)
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
        
        timer.increaseTime(by: 3)
        XCTAssertEqual(defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue), 1)
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
    }
    
    func testDecreaseCountdownTime() {
        let mockDelegate = MockCountdownDelegate()
        let configuration = CountdownConfiguration(minCountdownDuration: 0)
        let timer = Countdown(delegate: mockDelegate, countdownConfiguration: configuration, defaults: MockUserDefaults())
        timer.startCountdown(with: Date().addingTimeInterval(4))
        
        var expectedResult = DateComponents()
        expectedResult.second = 3
        
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
        
        timer.decreaseTime(by: 2)
        expectedResult.second = 1
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
    }
    
    func testDecreaseCountdownTimeOverZero() {
        let mockDelegate = MockCountdownDelegate()
        let defaults = MockUserDefaults()
        let configuration = CountdownConfiguration(minCountdownDuration: 1, defaultCountdownDuration: 10)
        let timer = Countdown(delegate: mockDelegate, countdownConfiguration: configuration, defaults: defaults)
        timer.startCountdown(with: Date().addingTimeInterval(4))
        
        var expectedResult = DateComponents()
        expectedResult.second = 3
        
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
        XCTAssertEqual(defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue), 10)
        
        timer.decreaseTime(by: 200)
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
        XCTAssertEqual(defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue), 10)
        
        timer.decreaseTime(by: 2)
        expectedResult.second = 1
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
        XCTAssertEqual(defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue), 8)
    }
    
    func testSkipRunningCountdownTests() {
        let timerDidFinishExpectation = self.expectation(description: "timerDidFinish")
        timerDidFinishExpectation.expectedFulfillmentCount = 1
        let mockDelegate = MockCountdownDelegate()
        mockDelegate.timerDidFinishExpectation = timerDidFinishExpectation
        let mockNotificationCenter = UserNotificationCenterMock()
        let timer = Countdown(delegate: mockDelegate, userNotificationCenter: mockNotificationCenter)
        
        XCTAssertEqual(mockNotificationCenter.pendingNotifications.count, 0)
        XCTAssertNil(timer.currentRuntime())
        
        let mockContent = UNMutableNotificationContent()
        mockContent.title = "title"
        mockContent.body = "body"
        
        timer.startCountdown(with: Date().addingTimeInterval(1), with: mockContent)
        XCTAssertNotNil(timer.currentRuntime())
        XCTAssertEqual(mockNotificationCenter.pendingNotifications.count, 1)
        
        timer.skipRunningCountdown()
        XCTAssertNil(timer.currentRuntime())
        waitForExpectations(timeout: 1)
        XCTAssertEqual(mockNotificationCenter.pendingNotifications.count, 0)
    }
    
    func testNotificationsWithoutAuthorizationStatusNotDetermined() {
        UNNotificationSettings.swizzleAuthorizationStatus()
        UNNotificationSettings.fakeAuthorizationStatus = .notDetermined
        
        let mockCenter = UserNotificationCenterMock()
        let mockCoder = MockNSCoder()
        mockCenter.settingsCoder = mockCoder
        let mockDelegate = MockCountdownDelegate()
        let defaults = MockUserDefaults()
        let timer = Countdown(delegate: mockDelegate, defaults: defaults, userNotificationCenter: mockCenter)
        
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
        
        let mockContent = UNMutableNotificationContent()
        mockContent.title = "title"
        mockContent.body = "body"
        
        timer.startCountdown(with: Date().addingTimeInterval(1), with: mockContent)
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
        
        timer.skipRunningCountdown()
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
    }
    
    func testNotificationsWithoutAuthorizationStatusDenied() {
        UNNotificationSettings.swizzleAuthorizationStatus()
        UNNotificationSettings.fakeAuthorizationStatus = .denied
        
        let mockCenter = UserNotificationCenterMock()
        let mockCoder = MockNSCoder()
        mockCenter.settingsCoder = mockCoder
        let mockDelegate = MockCountdownDelegate()
        let defaults = MockUserDefaults()
        let timer = Countdown(delegate: mockDelegate, defaults: defaults, userNotificationCenter: mockCenter)
        
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
        
        let mockContent = UNMutableNotificationContent()
        mockContent.title = "title"
        mockContent.body = "body"
        
        timer.startCountdown(with: Date().addingTimeInterval(1), with: mockContent)
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
        
        timer.skipRunningCountdown()
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
    }
    
    func testNotificationsWithoutAuthorizationStatusAuthorized() {
        UNNotificationSettings.swizzleAuthorizationStatus()
        UNNotificationSettings.fakeAuthorizationStatus = .authorized
        
        let mockCenter = UserNotificationCenterMock()
        let mockCoder = MockNSCoder()
        mockCenter.settingsCoder = mockCoder
        let mockDelegate = MockCountdownDelegate()
        let defaults = MockUserDefaults()
        let timer = Countdown(delegate: mockDelegate, defaults: defaults, userNotificationCenter: mockCenter)
        
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
        
        let mockContent = UNMutableNotificationContent()
        mockContent.title = "title"
        mockContent.body = "body"
        
        timer.startCountdown(with: Date().addingTimeInterval(1), with: mockContent)
        XCTAssertEqual(mockCenter.pendingNotifications.count, 1)
        
        timer.skipRunningCountdown()
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
    }
    
    func testNotificationsWithoutAuthorizationStatusProvisional() {
        UNNotificationSettings.swizzleAuthorizationStatus()
        UNNotificationSettings.fakeAuthorizationStatus = .provisional
        
        let mockCenter = UserNotificationCenterMock()
        let mockCoder = MockNSCoder()
        mockCenter.settingsCoder = mockCoder
        let mockDelegate = MockCountdownDelegate()
        let defaults = MockUserDefaults()
        let timer = Countdown(delegate: mockDelegate, defaults: defaults, userNotificationCenter: mockCenter)
        
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
        
        let mockContent = UNMutableNotificationContent()
        mockContent.title = "title"
        mockContent.body = "body"
        
        timer.startCountdown(with: Date().addingTimeInterval(1), with: mockContent)
        XCTAssertEqual(mockCenter.pendingNotifications.count, 1)
        
        timer.skipRunningCountdown()
        XCTAssertEqual(mockCenter.pendingNotifications.count, 0)
    }
    
    func testInvalidateRestoreCountdown() {
        let mockDefaults = MockUserDefaults()
        let countdown = Countdown(delegate: MockCountdownDelegate(), defaults: mockDefaults)
        
        XCTAssertNil(mockDefaults.value(forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue))
        
        countdown.startCountdown(with: Date.distantFuture)
        XCTAssertNotNil(countdown.currentRuntime())
        XCTAssertNil(mockDefaults.value(forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue))
        
        countdown.invalidate()
        XCTAssertNotNil(countdown.currentRuntime())
        XCTAssertNotNil(mockDefaults.value(forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue))
        
        countdown.restore()
        XCTAssertNotNil(countdown.currentRuntime())
        XCTAssertNil(mockDefaults.value(forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue))
        
        countdown.skipRunningCountdown()
        XCTAssertNil(countdown.currentRuntime())
        XCTAssertNil(mockDefaults.value(forKey: UserDefaultsConstants.countdownSavedFinishedDate.rawValue))
    }

    static var allTests = [
        ("testStartCountDownTimerDidFireItsCallbacks", testStartCountDownTimerDidFireItsCallbacks),
        ("testStartCountDown2TimerDidFireItsCallbacks", testStartCountDown2TimerDidFireItsCallbacks),
        ("testcurrentRuntime", testcurrentRuntime),
        ("testIncreaseCountdownTime", testIncreaseCountdownTime),
        ("testIncreaseCountdownTimeOverMaxTime", testIncreaseCountdownTimeOverMaxTime),
        ("testDecreaseCountdownTime", testDecreaseCountdownTime),
        ("testDecreaseCountdownTimeOverZero", testDecreaseCountdownTimeOverZero),
        ("testSkipRunningCountdownTests", testSkipRunningCountdownTests),
        ("testInvalidateRestoreCountdown", testInvalidateRestoreCountdown),
    ]
}

class MockCountdownDelegate: CountdownDelegate {
    var timerDidFireExpectation: XCTestExpectation?
    var timerDidFinishExpectation: XCTestExpectation?
    
    func timerDidFire(with currentTime: DateComponents) {
        timerDidFireExpectation?.fulfill()
    }
    
    func timerDidFinish() {
        timerDidFinishExpectation?.fulfill()
    }
}

class MockUserDefaults: UserDefaults {
}

extension UNNotificationSettings {
    static var fakeAuthorizationStatus: UNAuthorizationStatus = .authorized
    
    static func swizzleAuthorizationStatus() {
        let originalMethod = class_getInstanceMethod(self, #selector(getter: authorizationStatus))!
        let swizzledMethod = class_getInstanceMethod(self, #selector(getter: swizzledAuthorizationStatus))!
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc var swizzledAuthorizationStatus: UNAuthorizationStatus {
        return Self.fakeAuthorizationStatus
    }
}

class UserNotificationCenterMock: UserNotificationCenter {
    
    var pendingNotifications = [UNNotificationRequest]()
    var settingsCoder = MockNSCoder()
    
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        let settings = UNNotificationSettings(coder: settingsCoder)!
        completionHandler(settings)
    }
    
    func removeAllPendingNotificationRequests() {
        pendingNotifications.removeAll()
    }
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        pendingNotifications.append(request)
        completionHandler?(nil)
    }
}

class MockNSCoder: NSCoder {
    var authorizationStatus = UNAuthorizationStatus.authorized.rawValue
    
    override func decodeInt64(forKey key: String) -> Int64 {
        return Int64(authorizationStatus)
    }
    
    override func decodeBool(forKey key: String) -> Bool {
        return true
    }
}
