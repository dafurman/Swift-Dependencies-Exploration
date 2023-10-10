import Dependencies
import XCTest
@testable import SwiftDeps

final class LeakageTests: XCTestCase {

    override func invokeTest() {
        if name.contains("WithDefaultDependencies") {
            withDefaultDependencies {
                super.invokeTest()
            }
        } else {
            super.invokeTest()
        }
    }

    // MARK: - testAsyncDependencyMutationDoesNotLeak

    /// This kicks off an async mutation of the analytics dependency.
    func testAsyncDependencyMutationDoesNotLeakPart1() {
        withDependencies {
            $0.analytics = AnalyticsMock()
        } operation: {
            TestObject().trackAction(named: "Part1", after: .milliseconds(10))
        }
    }

    /// We want to verify that the async mutation from `testAsyncDependencyMutationDoesNotLeakPart1()` doesn't affect this test.
    func testAsyncDependencyMutationDoesNotLeakPart2() async throws {
        // simulate time passing between different tests running
        try await Task.sleep(for: .milliseconds(15))

        let analytics = AnalyticsMock()
        withDependencies {
            $0.analytics = analytics
        } operation: {
            TestObject().trackAction(named: "Part1", after: .milliseconds(10))
        }
        await Task.yield() // Yield to the Task that tracks the action

        XCTAssertEqual(analytics.events, [])
    }

    // MARK: - testAsyncDependencyMutationOnDefaultDependencyLeaks

    func testAsyncDependencyMutationOnDefaultDependencyLeaksPart1() async throws {
        TestObject().trackAction(named: "One", after: .milliseconds(10))
    }

    /// This demonstrates that we must avoid using default `testValue` values if they're going to be mutated asynchronously. *This test must be run as part of the suite to pass.*
    func testAsyncDependencyMutationOnDefaultDependencyLeaksPart2() async throws {
        let analytics = DependencyValues._current.analytics as! AnalyticsMock
        try await Task.sleep(for: .milliseconds(15))

        XCTAssertEqual(analytics.events, ["One"])
        // 💥😱 This assertion passes if the test is run on its own, but it fails if the test is run with testAsyncDependencyMutationOnDefaultDependencyLeaksPart1().
        XCTExpectFailure {
            // What we wanted the value to be:
            XCTAssertEqual(analytics.events, [])
        }
    }

    func test_WithDefaultDependencies_OnDefaultDependencyPreventsLeaksPart1() async throws {
        TestObject().trackAction(named: "One", after: .milliseconds(10))
    }

    func test_WithDefaultDependencies_OnDefaultDependencyPreventsLeaksPart2() async throws {
        let analytics = DependencyValues._current.analytics as! AnalyticsMock
        try await Task.sleep(for: .milliseconds(15))

        XCTAssertEqual(analytics.events, [])
    }

}

private final class TestObject {
    @Dependency(\.analytics) private var analytics

    func trackAction(named name: String, after delay: Duration = .zero) {
        Task {
            if delay != .zero {
                try await Task.sleep(for: delay)
            }
            analytics.trackEvent(named: name)
        }
    }
}
