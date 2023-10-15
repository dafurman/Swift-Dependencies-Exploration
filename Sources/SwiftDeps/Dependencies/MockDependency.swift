import Dependencies
import Foundation
import XCTest

@propertyWrapper
public struct MockDependency<Value, MockType>: @unchecked Sendable {
    private let keyPath: KeyPath<DependencyValues, Value>
    private let file: StaticString
    private let fileID: StaticString
    private let line: UInt

    /// Creates a dependency property to read the specified key path.
    ///
    /// Don't call this initializer directly. Instead, declare a property with the `MockDependency`
    /// property wrapper, and provide protocol type, the mock type, and the key path of the dependency value that the property should
    /// reflect:
    ///
    /// ```swift
    /// class MyTestCase: XCTestCase {
    ///   @MockDependency<AnalyticsProtocol, AnalyticsMock>(\.analytics) var analytics
    ///
    ///   // ...
    /// }
    /// ```
    ///
    /// - Parameter keyPath: A key path to a specific resulting value.
    /// - Parameter mockType: The type of the mock that should be returned. This must match the type used to instantiate the dependency's `testValue`.
    public init(
        _ keyPath: KeyPath<DependencyValues, Value>,
        _ mockType: MockType.Type,
        file: StaticString = #file,
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) {
        self.keyPath = keyPath
        self.file = file
        self.fileID = fileID
        self.line = line
    }

    /// The current value of the dependency property, cast to the `MockType`.
    public var wrappedValue: MockType {
        @Dependency(keyPath, file: file, fileID: fileID, line: line) var dependency

        do {
            return try XCTUnwrap(dependency as? MockType, "Failed to cast the dependency to the specified mock type. Use the mock type that's constructed in the dependency's testValue.")
        } catch {
            fatalError("A fatal error occured while unwrapping a dependency as a mock: \(error)")
        }
    }
}
