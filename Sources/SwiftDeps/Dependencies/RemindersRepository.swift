import Dependencies
import Foundation

// MARK: - RemindersRepository

public struct RemindersRepository {
    public var _fetchReminders: (() async throws -> [Reminder])

    init(fetchReminders: @escaping () async throws -> [Reminder]) {
        self._fetchReminders = fetchReminders
    }

    func fetchReminders() async throws -> [Reminder] {
        try await _fetchReminders()
    }
}

extension RemindersRepository {
    static var live: Self {
        .init { ["Some Real Reminder"] }
    }

    static var infiniteLoadingMock: Self {
        .init {
            try await Task.sleep(for: .infinity)
            assertionFailure("This shouldn't be reached")
            return []
        }
    }

    static var oneReminderMock: Self {
        .init { ["Walk Dog 🐶"] }
    }

    static var errorMock: Self {
        .init { throw MockError.fakeError }
    }
}

// MARK: - Dependencies

extension DependencyValues {
    public var remindersRepository: RemindersRepository {
        get { self[RemindersRepositoryKey.self] }
        set { self[RemindersRepositoryKey.self] = newValue }
    }

    private enum RemindersRepositoryKey: DependencyKey {
        static let liveValue: RemindersRepository = .live
        static var testValue: RemindersRepository { .errorMock }
        static var previewValue: RemindersRepository { .errorMock }
    }
}

public extension Dependencies {
    static var remindersRepository: RemindersRepository {
        @Dependency(\.remindersRepository) var remindersRepository
        return remindersRepository
    }
}
