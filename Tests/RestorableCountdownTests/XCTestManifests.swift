#if !canImport(ObjectiveC)
import XCTest

extension CountdownNotificationBuilderTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CountdownNotificationBuilderTests = [
        ("testBuild", testBuild),
    ]
}

extension CountdownTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CountdownTests = [
        ("testcurrentRuntime", testcurrentRuntime),
        ("testDecreaseCountdownTime", testDecreaseCountdownTime),
        ("testDecreaseCountdownTimeOverZero", testDecreaseCountdownTimeOverZero),
        ("testIncreaseCountdownTime", testIncreaseCountdownTime),
        ("testIncreaseCountdownTimeOverMaxTime", testIncreaseCountdownTimeOverMaxTime),
        ("testInvalidateRestoreCountdown", testInvalidateRestoreCountdown),
        ("testSkipRunningCountdownTests", testSkipRunningCountdownTests),
        ("testStartCountDown2TimerDidFireItsCallbacks", testStartCountDown2TimerDidFireItsCallbacks),
        ("testStartCountDownTimerDidFireItsCallbacks", testStartCountDownTimerDidFireItsCallbacks),
    ]
}

extension DateComponentsTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DateComponentsTests = [
        ("testDateComponentsForTimeIntervalLong", testDateComponentsForTimeIntervalLong),
        ("testDateComponentsForTimeIntervalShort", testDateComponentsForTimeIntervalShort),
        ("testDateComponentsForTimeIntervalSuperLong", testDateComponentsForTimeIntervalSuperLong),
        ("testTimeInterval", testTimeInterval),
        ("testTimeInterval2", testTimeInterval2),
        ("testTimeIntervalDisregardingMonthYear", testTimeIntervalDisregardingMonthYear),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CountdownNotificationBuilderTests.__allTests__CountdownNotificationBuilderTests),
        testCase(CountdownTests.__allTests__CountdownTests),
        testCase(DateComponentsTests.__allTests__DateComponentsTests),
    ]
}
#endif