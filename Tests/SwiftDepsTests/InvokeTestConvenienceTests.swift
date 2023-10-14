import Dependencies
import Foundation
import XCTest
@testable import SwiftDeps

class InvokeTestConvenienceTests: XCTestCase {

    // Can I set this up automatically for all dependencies available to a base class? Loop through them?
    // I've proven we can mutate this without issue, so if we can do this, it'd mean there's no need for withDependencies()!
    var analytics: AnalyticsMock!

    override func invokeTest() {
        if name.contains("ConvenientInvokeTest") {
            analytics = DependencyValues._current.analytics as? AnalyticsMock
            withDependencies {
                $0.analytics = analytics
            } operation: {
                super.invokeTest()
            }
        } else {
            super.invokeTest()
        }
    }

    // MARK: - Default
    // These leak asynchronously ❌

    func testDefault1() async throws {
        analytics = DependencyValues._current.analytics as? AnalyticsMock
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

    func testDefault2() async throws {
        analytics = DependencyValues._current.analytics as? AnalyticsMock
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

    func testDefault3() async throws {
        analytics = DependencyValues._current.analytics as? AnalyticsMock
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

    func testDefault4() async throws {
        analytics = DependencyValues._current.analytics as? AnalyticsMock
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

    func testDefault5() async throws {
        analytics = DependencyValues._current.analytics as? AnalyticsMock
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
    }

    // MARK: - Invoke convenience
    // These don't leak asynchronously 👍

    func testWithConvenientInvokeTest1() async throws {
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

    func testWithConvenientInvokeTest2() async throws {
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

    func testWithConvenientInvokeTest3() async throws {
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

    func testWithConvenientInvokeTest4() async throws {
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

    func testWithConvenientInvokeTest5() async throws {
        try await Task.sleep(for: .milliseconds(15))
        let manualEvent = "manual insert \(#function)" // In order to verify this isn't kept around from test to test.
        analytics.events.append(manualEvent)
        XCTAssertEqual(analytics.events, [manualEvent])
        TestObject().trackAction(named: #function, after: .milliseconds(10))
    }

}
