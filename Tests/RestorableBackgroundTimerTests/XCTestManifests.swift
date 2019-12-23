import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CountdownTests.allTests),
        testCase(DateComponentsTests.allTests),
        testCase(CountdownApplicationServiceTests.allTests),
    ]
}
#endif
