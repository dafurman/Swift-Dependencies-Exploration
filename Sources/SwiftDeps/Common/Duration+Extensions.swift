import Foundation

extension Duration {
    static var infinity: Self {
        .seconds(1_000_000_000_000) // The user would be dead for literal eons at this point...so we can use this to approximate infinity.
    }
}
