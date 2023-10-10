import Foundation

public struct Reminder: Identifiable, Equatable, CustomStringConvertible {
    let title: String
    public var id: String { title }

    public var description: String { title }
}

extension Reminder: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}

extension Reminder: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.title = value
    }
}
