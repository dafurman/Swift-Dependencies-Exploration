import Dependencies
import Foundation

public protocol AnalyticsProtocol: AnyObject {
    var id: String { get }
    func trackEvent(named: String)
}

public class Analytics: AnalyticsProtocol {
    public let id: String

    init(id: String = "") {
        self.id = id
    }

    public func trackEvent(named: String) {}
}

public class AnalyticsMock: AnalyticsProtocol, ObservableObject {
    public var id: String
    public var events: [String] = []

    init(id: String = #function) {
        self.id = id
    }

    public func trackEvent(named name: String) {
        print("🟢 Tracking event: \(name) in \(id)'s analytics")
        events.append(name)
    }
}

// MARK: - Dependencies

extension DependencyValues {
    public var analytics: AnalyticsProtocol {
        get { self[AnalyticsKey.self] }
        set { self[AnalyticsKey.self] = newValue }
    }

    private enum AnalyticsKey: DependencyKey {
        static let liveValue: AnalyticsProtocol = Analytics()
        static var testValue: AnalyticsProtocol { AnalyticsMock() }
    }
}

public extension Dependencies {
    static var analytics: AnalyticsProtocol {
        @Dependency(\.analytics) var analytics
        return analytics
    }
}
