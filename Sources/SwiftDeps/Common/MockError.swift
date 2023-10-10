import Foundation

enum MockError: String, LocalizedError {
    case unmocked = "unmocked"
    case fakeError = "Fake Error"

    var errorDescription: String? {
        rawValue
    }
}
