//
//  CountdownApplicationServiceTests.swift
//  RestorableBackgroundTimerTests
//
//  Created by Jonas Reichert on 23.12.19.
//

import XCTest
@testable import RestorableBackgroundTimer

#if canImport(UIKit)
class CountdownApplicationServiceTests: XCTestCase {

    var countdownRestorable: MockCountdownRestorable!
    var countdownApplicationService: CountdownApplicationService!
    let mockNotificationCenter = MockNotificationCenter()
    
    func testRegister() {
        countdownApplicationService = CountdownApplicationService(notificationCenter: mockNotificationCenter)
        countdownRestorable = MockCountdownRestorable(delegate: MockCountdownDelegate(), defaults: MockUserDefaults(), countdownApplicationService: countdownApplicationService)
        
        countdownApplicationService.register()
        
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 0)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 0)
        
        mockNotificationCenter.triggerWillResignActive()
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 1)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 0)
        
        mockNotificationCenter.triggerDidBecomeActive()
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 1)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 1)
        
        mockNotificationCenter.triggerWillResignActive()
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 2)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 1)
    }
    
    func testDeregister() {
        countdownApplicationService = CountdownApplicationService(notificationCenter: mockNotificationCenter)
        countdownRestorable = MockCountdownRestorable(delegate: MockCountdownDelegate(), defaults: MockUserDefaults(), countdownApplicationService: countdownApplicationService)
        
        countdownApplicationService.register()
        
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 0)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 0)
        
        mockNotificationCenter.triggerWillResignActive()
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 1)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 0)
        
        mockNotificationCenter.triggerDidBecomeActive()
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 1)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 1)
        
        countdownApplicationService.deregister()
        
        mockNotificationCenter.triggerWillResignActive()
        mockNotificationCenter.triggerDidBecomeActive()
        
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 1)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 1)
        
        countdownApplicationService.register()
        
        mockNotificationCenter.triggerWillResignActive()
        mockNotificationCenter.triggerDidBecomeActive()
        
        XCTAssertEqual(countdownRestorable.invalidateCalledCount, 2)
        XCTAssertEqual(countdownRestorable.restoreCalledCount, 2)
    }

}

class MockCountdownRestorable: Countdown {
    var invalidateCalledCount = 0
    var restoreCalledCount = 0
    
    override func invalidate() {
        invalidateCalledCount += 1
    }
    
    override func restore() {
        restoreCalledCount += 1
    }
}

class MockNotificationCenter: NotificationCenter {
    func triggerWillResignActive() {
        self.post(Notification(name: UIApplication.willResignActiveNotification))
    }
    
    func triggerDidBecomeActive() {
        self.post(Notification(name: UIApplication.didBecomeActiveNotification))
    }
}
#endif
