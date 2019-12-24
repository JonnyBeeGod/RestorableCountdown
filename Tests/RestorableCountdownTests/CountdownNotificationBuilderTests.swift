//
//  CountdownNotificationBuilderTests.swift
//  RestorableBackgroundTimerTests
//
//  Created by Jonas Reichert on 23.12.19.
//

import XCTest
import UserNotifications
@testable import RestorableBackgroundTimer

class CountdownNotificationBuilderTests: XCTestCase {
    
    let notificationBuilder: CountdownNotificationBuilding = CountdownNotificationBuilder()

    func testBuild() {
        let content = UNMutableNotificationContent()
        content.title = "mockTitle"
        content.body = "mockBody"
        
        let expectedTriggerDate = Date().addingTimeInterval(123456)
        let request = notificationBuilder.build(content: content, scheduledDate: expectedTriggerDate)
        
        XCTAssertEqual(request.content, content)
        
        guard let calenderTrigger = request.trigger as? UNCalendarNotificationTrigger else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(calenderTrigger.nextTriggerDate(), expectedTriggerDate)
    }
    
    static var allTests = [
        ("testBuild", testBuild),
    ]

}
