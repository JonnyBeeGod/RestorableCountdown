import XCTest
@testable import RestorableBackgroundTimer

final class RestorableBackgroundTimerTests: XCTestCase {
    var timer: Countdown!
    var timerDidFireExpectation: XCTestExpectation!
    var timerDidFinishExpectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        timer = Countdown(delegate: self)
        timerDidFireExpectation = self.expectation(description: "timerDidFire")
        timerDidFireExpectation.expectedFulfillmentCount = 10 // at least 10 time fired combined because 2 tests start countdowns
        timerDidFireExpectation.assertForOverFulfill = false
        
        timerDidFinishExpectation = self.expectation(description: "timerDidFinish")
        timerDidFireExpectation.expectedFulfillmentCount = 2 // exactly 2 times fired combined because 2 tests start the countdowns
        timerDidFinishExpectation.assertForOverFulfill = true
    }
    
    func testStartCountDownTimerDidFireItsCallbacks() {
        timer.startCountdown(with: Date().addingTimeInterval(1))
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testStartCountDown2TimerDidFireItsCallbacks() {
        var components = DateComponents()
        components.second = 1
        timer.startCountdown(with: components)
        waitForExpectations(timeout: 2, handler: nil)
    }

    static var allTests = [
        ("testStartCountDownTimerDidFireItsCallbacks", testStartCountDownTimerDidFireItsCallbacks),
    ]
}

extension RestorableBackgroundTimerTests: CountdownDelegate {
    func timerDidFire(with currentTime: DateComponents) {
        timerDidFireExpectation.fulfill()
    }
    
    func timerDidFinish() {
        timerDidFinishExpectation.fulfill()
    }
    
    
}
