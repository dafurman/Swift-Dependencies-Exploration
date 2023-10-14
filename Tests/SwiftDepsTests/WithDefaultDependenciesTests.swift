import Dependencies
import Foundation
import SwiftUI
@testable import SwiftDeps
import XCTest

/// `withDefaultDependencies()` seems like a viable workaround to the async flakiness of `testValue`. We can use this in base test classes to invoke tests.
///
/// Unfortunately, when we use this, we have to be more careful with how we use dependencies inside of`.task()`, and must use `withDependencies(from: self)`more. If we don't use that, main code will try to use a new dependency instance instead of the one passed through `withDefaultDependencies()`.
class WithDefaultDependenciesTests: SnapshotTestCase {

    override func invokeTest() {
        let adjustedName = name.replacingOccurrences(of: "WithDefaultDependenciesTests", with: "")

        if adjustedName.contains("WithDefaultDependencies") {
            withDefaultDependencies {
                super.invokeTest()
            }
        } else {
            super.invokeTest()
        }
    }

    /// This test works just fine, but it doesn't use `withDefaultDependencies()`.
    func testTaskAnalytics() throws {
        let analytics = try XCTUnwrap(Dependencies.analytics as? AnalyticsMock)
        analytics.trackEvent(named: "testLayoutPart1") // Insert an event just to verify that the code adjusts the correct analytics instance here.
        print(analytics.id)

        // Just do verification to kick off the view running its .task(). We don't care about the result.
        XCTExpectFailure {
            verify(RemindersView(), delay: 0.1)
        }
        XCTAssertEqual(analytics.events, ["testLayoutPart1", "task()", "staticTask()"])
    }

    /// This test demonstrates an issue with `withDefaultDependencies()`: Dependencies used in a `.task()` must be grabbed via a `@Dependency` property wrapper as a stored property, not through `Dependencies.<myDependency>`
    func testTaskAnalytics_WithDefaultDependencies() throws {
        let analytics = try XCTUnwrap(Dependencies.analytics as? AnalyticsMock)
        analytics.trackEvent(named: "testLayoutPart1") // Insert an event just to verify that the code adjusts the correct analytics instance here.
        print(analytics.id)

        // Just do verification to kick off the view running its .task(). We don't care about the result.
        XCTExpectFailure {
            verify(RemindersView(), delay: 0.1)
        }
        XCTAssertEqual(analytics.events, ["testLayoutPart1", "task()", "staticTask()"])
    }

    // MARK: - testStaticConst

    func testStaticConst_WithDefaultDependencies_Part1() async throws {
        let analytics = Dependencies.analytics as! AnalyticsMock
        MyNestedStuff.testObject.trackAction(named: "Part1")
        try await Task.sleep(for: .milliseconds(10))
        XCTAssertEqual(analytics.events, ["Part1"])
    }

    /// Unfortunately, WithDefaultDependencies causes new leakage in static constants.
    /// Part 2 will reuse Part 1's analytics.
    /// The only way this will work is if TestObject doesn't store the analytics @Dependency, but instead grabs it within the scope of the function. Making that change gets this test passing.
    func testStaticConst_WithDefaultDependencies_Part2() async throws {
        let analytics = Dependencies.analytics as! AnalyticsMock
        MyNestedStuff.testObject.trackAction(named: "Part2")
        try await Task.sleep(for: .milliseconds(10))

//        XCTAssertEqual(analytics.events, [])
        XCTAssertEqual(analytics.events, ["Part2"])
//        XCTExpectFailure {
//            // What we wanted the value to be:
//        }
    }

}

enum MyNestedStuff {
    static let testObject = TestObject()
}
