import Dependencies
import Foundation
import XCTest
@testable import SwiftDeps

/// This is an example where an  `ObjectA` uses a dependency `ObjectB` to manipulate a dependency `ObjectC`.
/// In reality, we should strive to isolate dependencies from one another, but this tests and provides a solution for that situation.
final class NestingTests: XCTestCase {

    /// Using default `testValue`s lets us avoid any complex withDependencies setup, which is nice.
    func testNestingWithDefaults() {
        let a = ObjectA()
        let b = Dependencies.objectB
        let c = Dependencies.objectC

        XCTAssertNil(b.value)
        XCTAssertNil(c.value)
        a.useBtoUpdateCValue(to: "MyNewValue")
        XCTAssertEqual(b.value, "MyNewValue")
        XCTAssertEqual(c.value, "MyNewValue")
    }

    /// This is an easy mistake to make, and can result in incorrect behavior.
    func testBadNestingWithDependencies() {
        let c = ObjectC()
        let b = ObjectB()
        let a = withDependencies {
            $0.objectB = b
            $0.objectC = c
        } operation: {
            ObjectA()
        }
        XCTAssertNil(b.value)
        XCTAssertNil(c.value)
        a.useBtoUpdateCValue(to: "MyNewValue")
        XCTAssertEqual(b.value, "MyNewValue")
        XCTAssertNil(c.value)

        XCTExpectFailure {
            // What we wanted the value to be:
            XCTAssertEqual(c.value, "MyNewValue")
        }
    }

    /// We need to do this to get one dependency to use another. It makes sense, but it's structurally complex, so it should be documented for devs to be aware of this pattern.
    func testGoodNestingWithDependencies() {
        let c = ObjectC()
        var b: ObjectB?
        let a = withDependencies {
            $0.objectB = withDependencies({
                $0.objectC = c
            }, operation: {
                b = ObjectB()
                return b!
            })
            $0.objectC = c
        } operation: {
            ObjectA()
        }
        XCTAssertNil(b?.value)
        XCTAssertNil(c.value)
        a.useBtoUpdateCValue(to: "MyNewValue")

        XCTAssertEqual(b?.value, "MyNewValue")
        XCTAssertEqual(c.value, "MyNewValue")
    }

}

private class ObjectA {
    @Dependency(\.objectB) private var objectB

    func useBtoUpdateCValue(to newValue: String) {
        objectB.updateValueWithC(to: newValue)
    }
}

private class ObjectB {
    @Dependency(\.objectC) private var objectC
    private(set) var value: String?

    func updateValueWithC(to newValue: String) {
        value = newValue
        objectC.updateValue(to: newValue)
    }
}

private class ObjectC {
    private(set) var value: String?

    func updateValue(to newValue: String) {
        value = newValue
    }
}

private extension DependencyValues {
    var objectB: ObjectB {
        get { self[ObjectBKey.self] }
        set { self[ObjectBKey.self] = newValue }
    }

    private enum ObjectBKey: DependencyKey {
        static let liveValue = ObjectB()
        static var testValue: ObjectB { ObjectB() }
    }
}

private extension DependencyValues {
    var objectC: ObjectC {
        get { self[ObjectCKey.self] }
        set { self[ObjectCKey.self] = newValue }
    }

    private enum ObjectCKey: DependencyKey {
        static let liveValue = ObjectC()
        static var testValue: ObjectC { ObjectC() }
    }
}

private extension Dependencies {
    static var objectB: ObjectB {
        @Dependency(\.objectB) var objectB
        return objectB
    }

    static var objectC: ObjectC {
        @Dependency(\.objectC) var objectC
        return objectC
    }
}
