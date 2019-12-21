import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(RestorableBackgroundTimerTests.allTests),
        testCase(DateComponentsTests.allTests),
    ]
}
#endif
