import Dependencies
import Foundation

// MARK: - RemindersRepository

struct FeatureFlags {
    let enabledFeatures: Set<Feature>

    init(enabledFeatures: Set<Feature> = []) {
        self.enabledFeatures = enabledFeatures
    }

    func isFeatureEnabled(_ feature: Feature) -> Bool {
        enabledFeatures.contains(feature)
    }
}

public enum Features {
    public enum BlueLoading {
        @Dependency(\.featureFlags) private static var featureFlags
        static var isEnabled: Bool {
            featureFlags.isFeatureEnabled(.blueLoading)
        }
    }
}

public enum Feature: Hashable {
    case blueLoading
}

// MARK: - Dependencies

extension DependencyValues {
    var featureFlags: FeatureFlags {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private enum Key: DependencyKey {
        static let liveValue: FeatureFlags = FeatureFlags()
        static var testValue: FeatureFlags { FeatureFlags() }
        static var previewValue: FeatureFlags { FeatureFlags() }
    }
}

extension Dependencies {
    static var featureFlags: FeatureFlags {
        @Dependency(\.featureFlags) var featureFlags
        return featureFlags
    }
}
