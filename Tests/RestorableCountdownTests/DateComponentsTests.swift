//
//  DateComponentsTests.swift
//  RestorableBackgroundTimerTests
//
//  Created by Jonas Reichert on 21.12.19.
//

import XCTest
@testable import RestorableCountdown

class DateComponentsTests: XCTestCase {
    
    func testDateComponentsForTimeIntervalShort() {
        let superShort: TimeInterval = 0.000283764829
        var superShortExpectedResult = DateComponents()
        superShortExpectedResult.day = 0
        superShortExpectedResult.hour = 0
        superShortExpectedResult.minute = 0
        superShortExpectedResult.second = 0
        superShortExpectedResult.nanosecond = 283764
        
        XCTAssertEqual(DateComponents.dateComponents(for: superShort), superShortExpectedResult)
    }
    
    func testDateComponentsForTimeIntervalLong() {
        let long: TimeInterval = Double(13 + 51 * 60 + 14 * 60 * 60 + 7 * 60 * 60 * 24) // 7 days, 14 hours, 51 minutes and 13 seconds
        var longExpectedResult = DateComponents()
        longExpectedResult.day = 7
        longExpectedResult.hour = 14
        longExpectedResult.minute = 51
        longExpectedResult.second = 13
        longExpectedResult.nanosecond = 0
        
        XCTAssertEqual(DateComponents.dateComponents(for: long), longExpectedResult)
    }
    
    func testDateComponentsForTimeIntervalSuperLong() {
        let long: TimeInterval = Double(13 + 51 * 60 + 14 * 60 * 60 + 51 * 60 * 60 * 24) // 51 days, 14 hours, 51 minutes and 13 seconds
        var superLongExpectedResult = DateComponents()
        superLongExpectedResult.day = 51
        superLongExpectedResult.hour = 14
        superLongExpectedResult.minute = 51
        superLongExpectedResult.second = 13
        superLongExpectedResult.nanosecond = 0
        
        XCTAssertEqual(DateComponents.dateComponents(for: long), superLongExpectedResult)
    }
    
    func testTimeInterval() {
        var components = DateComponents()
        components.day = 13
        components.hour = 11
        components.minute = 23
        components.second = 55
        
        let expectedTimeInterval = 55 + 23 * 60 + 11 * 60 * 60 + 13 * 24 * 60 * 60
        
        XCTAssertEqual(components.timeInterval(), TimeInterval(exactly: expectedTimeInterval))
    }
    
    func testTimeInterval2() {
        var components = DateComponents()
        components.day = 0
        components.hour = 11
        components.minute = 23
        components.second = 0
        
        let expectedTimeInterval = 23 * 60 + 11 * 60 * 60
        
        XCTAssertEqual(components.timeInterval(), TimeInterval(exactly: expectedTimeInterval))
    }
    
    func testTimeIntervalDisregardingMonthYear() {
        var components = DateComponents()
        components.year = 2020
        components.month = 2
        components.day = 13
        components.hour = 11
        components.minute = 23
        components.second = 55
        
        let expectedTimeInterval = 55 + 23 * 60 + 11 * 60 * 60 + 13 * 24 * 60 * 60
        
        XCTAssertEqual(components.timeInterval(), TimeInterval(exactly: expectedTimeInterval))
    }
    
    func testTimeIntervalIncludeNanoseconds() {
        var components = DateComponents()
        components.day = 0
        components.hour = 11
        components.minute = 23
        components.second = 0
        components.nanosecond = 89675
        
        let expectedTimeInterval = 0.000089675 + 1380 + 39600
        
        XCTAssertEqual(components.timeInterval(), TimeInterval(exactly: expectedTimeInterval))
    }
    
    static var allTests = [
        ("testDateComponentsForTimeIntervalShort", testDateComponentsForTimeIntervalShort),
        ("testDateComponentsForTimeIntervalLong", testDateComponentsForTimeIntervalLong),
        ("testDateComponentsForTimeIntervalSuperLong", testDateComponentsForTimeIntervalSuperLong),
        ("testTimeInterval", testTimeInterval),
        ("testTimeInterval2", testTimeInterval2),
        ("testTimeIntervalDisregardingMonthYear", testTimeIntervalDisregardingMonthYear),
        ("testTimeIntervalIncludeNanoseconds", testTimeIntervalIncludeNanoseconds),
    ]

}
