import Dependencies

/// Performs an operation in a `withDependencies(_:operation:)` where all dependencies are using their default values from the current context.
func withDefaultDependencies(_ operation: () -> Void) {
    withDependencies {
        $0 = .current
    } operation: {
        operation()
    }
}

private extension DependencyValues {
    static var current: Self {
        var values = Self()
        values.context = DependencyValues._current.context
        return values
    }
}
