import XCTest
@testable import RestorableBackgroundTimer

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
        let configuration = CountdownConfiguration(maxCountdownDuration: 2, defaultCountdownDuration: 10)
        let timer = Countdown(delegate: mockDelegate, countdownConfiguration: configuration, defaults: defaults)
        timer.startCountdown(with: Date().addingTimeInterval(2))
        
        var expectedResult = DateComponents()
        expectedResult.second = 1
        
        XCTAssertEqual(defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue), 10)
        XCTAssertEqual(Double(timer.currentRuntime()?.second ?? 0), Double(expectedResult.second ?? 0), accuracy: 0.05)
        
        timer.increaseTime(by: 3)
        XCTAssertEqual(defaults.double(forKey: UserDefaultsConstants.currentSavedDefaultCountdownRuntime.rawValue), 10)
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
        let mockDefaults = MockUserDefaults()
        let timer = Countdown(delegate: mockDelegate, defaults: mockDefaults)
        
        XCTAssertNil(timer.currentRuntime())
        
        timer.startCountdown(with: Date().addingTimeInterval(1))
        XCTAssertNotNil(timer.currentRuntime())
        
        timer.skipRunningCountdown()
        XCTAssertNil(timer.currentRuntime())
        waitForExpectations(timeout: 1)
        
        // TODO: also test notification. Since injecting of default center crashes skip for now
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
    var timerDidFireExpectation: XCTestExpectation!
    var timerDidFinishExpectation: XCTestExpectation!
    
    func timerDidFire(with currentTime: DateComponents) {
        timerDidFireExpectation.fulfill()
    }
    
    func timerDidFinish() {
        timerDidFinishExpectation.fulfill()
    }
}

class MockUserDefaults: UserDefaults {
}
