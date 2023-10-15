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
    /// Don't call this initializer directly. Instead, declare a property with the `Dependency`
    /// property wrapper, and provide the key path of the dependency value that the property should
    /// reflect:
    ///
    /// ```swift
    /// final class FeatureModel: ObservableObject {
    ///   @Dependency(\.date) var date
    ///
    ///   // ...
    /// }
    /// ```
    ///
    /// - Parameter keyPath: A key path to a specific resulting value.
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

    /// The current value of the dependency property.
    public var wrappedValue: MockType {
        @Dependency(keyPath, file: file, fileID: fileID, line: line) var dependency

        do {
            return try XCTUnwrap(dependency as? MockType, "Failed to cast the dependency to the specified mock type. Use the mock type that's constructed in the dependency's testValue.")
        } catch {
            fatalError("A fatal error occured while unwrapping a dependency as a mock: \(error)")
        }
    }
}
